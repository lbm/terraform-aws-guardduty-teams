#!/usr/bin/env python3

"""Forward an AWS GuardDuty finding to Microsoft Teams via an incoming webhook.

Intended for usage as an AWS Lambda function with the Python 3.8 runtime.
"""

import json
import logging
import os
from typing import Any, Dict, Tuple
from urllib import request
import uuid

ENVIRONMENT_LABEL = os.getenv("ENVIRONMENT_LABEL")
SEVERITY_THRESHOLD = float(os.getenv("SEVERITY_THRESHOLD", "2.0"))
TEAMS_WEBHOOK_URL = os.getenv("TEAMS_WEBHOOK_URL")

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def info_for_severity(severity: float) -> Tuple[str, str]:
    """Returns an info tuple for a given severity level.

    Args:
        severity: The severity level of an AWS GuardDuty finding.

    Returns:
        A tuple of two strings. The first will describe the severity level as an English
        word and the second will provide a color for it as a hex triplet.
    """
    if 0.1 <= severity <= 3.9:
        return ("Low", "007ABC")
    if 4.0 <= severity <= 6.9:
        return ("Medium", "FEAE2C")
    if 7.0 <= severity <= 8.9:
        return ("High", "DF3312")

    return ("Unknown", "9B59B6")


def create_card(event_detail: Dict[str, Any]) -> Dict[str, Any]:
    """Creates a dictionary encoding the payload required to deliver a message to Teams.

    The payload follows the format of legacy actionable message cards:
    https://docs.microsoft.com/en-us/outlook/actionable-messages/message-card-reference

    Args:
        event_detail: The contents of `event["detail"]`, as forwarded to AWS Lambda.

    Returns:
        A dictionary intended to be used as a JSON payload. It encodes the payload of a
        legacy actionable message card representing an AWS GuardDuty finding.
    """
    severity_level, severity_color = info_for_severity(event_detail["severity"])

    headline = (
        f"AWS GuardDuty Finding in {ENVIRONMENT_LABEL} (Severity: {severity_level})"
    )
    url = f'https://{event_detail["region"]}.console.aws.amazon.com/guardduty/home?region={event_detail["region"]}#/findings?&fId={event_detail["id"]}'

    return {
        "@type": "MessageCard",
        "@context": "https://schema.org/extensions",
        "correlationId": str(uuid.uuid4()),
        "summary": headline,
        "themeColor": severity_color,
        "title": headline,
        "sections": [
            {
                "facts": [
                    {"name": "Finding ID", "value": event_detail["id"]},
                    {"name": "Type", "value": event_detail["type"]},
                    {"name": "Environment", "value": ENVIRONMENT_LABEL},
                    {"name": "Region", "value": event_detail["region"]},
                    {"name": "Occurred At", "value": event_detail["updatedAt"]},
                ],
                "text": event_detail["description"],
            }
        ],
        "potentialAction": [
            {
                "@type": "OpenUri",
                "name": "Open in AWS Management Console",
                "targets": [{"os": "default", "uri": url}],
            }
        ],
    }


def send_card(card: Dict[str, Any]) -> bool:
    """Sends a card created with `create_card(event_detail)` to Teams.

    Args:
        card: A card representing an AWS GuardDuty finding.

    Returns:
        True if the card was successfully delivered.
    """
    if not TEAMS_WEBHOOK_URL:
        logger.error("A `TEAMS_WEBHOOK_URL` environment variable was not provided")
        return False

    req = request.Request(TEAMS_WEBHOOK_URL)
    req.add_header("Content-type", "application/json")

    res = request.urlopen(req, json.dumps(card).encode())
    res.close()

    return True


def lambda_handler(event: Dict[str, Any], context: Any) -> None:
    event_detail = event["detail"]

    if event_detail["severity"] < SEVERITY_THRESHOLD:
        logger.info(f'Supressing finding with ID {event_detail["id"]}')
        return

    card = create_card(event_detail)

    if not send_card(card):
        logger.error(f'Failed to send alert for finding with ID {event_detail["id"]}')
        return

    logger.info(f'Sent alert with correlation ID {card["correlationId"]}')
