resource "aws_cloudwatch_log_group" "alert_teams" {
  name              = "/aws/lambda/${var.alert_teams_function_name}"
  retention_in_days = var.cloudwatch_expire_days
}

data "aws_iam_policy_document" "alert_teams_log_policy" {
  statement {
    effect    = "Allow"
    resources = ["${aws_cloudwatch_log_group.alert_teams.arn}:*"]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
  }
}

resource "aws_iam_policy" "alert_teams_log_policy" {
  name   = "${var.alert_teams_function_name}-cloudwatch-policy"
  policy = data.aws_iam_policy_document.alert_teams_log_policy.json
}

resource "aws_iam_role_policy_attachment" "alert_teams" {
  role       = aws_iam_role.alert_teams_role.name
  policy_arn = aws_iam_policy.alert_teams_log_policy.arn
}

resource "aws_cloudwatch_event_rule" "forward_finding_rule" {
  name        = "forward-guardduty-finding-to-teams"
  description = "Triggers a lambda function that alerts Teams whenever a GuardDuty finding is updated."

  event_pattern = <<EOF
{
  "source": [
    "aws.guardduty"
  ],
  "detail-type": [
    "GuardDuty Finding"
  ],
  "detail": {
    "severity": [
      0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 1.0,
      1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2, 2.0,
      2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3, 3.0,
      3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 4, 4.0,
      4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 5, 5.0,
      5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 6, 6.0,
      6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 6.9, 7, 7.0,
      7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 7.9, 8, 8.0,
      8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8, 8.9
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "forward_finding_target" {
  rule = aws_cloudwatch_event_rule.forward_finding_rule.name
  arn  = aws_lambda_function.alert_teams_function.arn
}
