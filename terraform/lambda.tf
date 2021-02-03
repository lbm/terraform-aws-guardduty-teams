resource "aws_iam_role" "alert_teams_role" {
  name               = "${var.alert_teams_function_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_lambda_function" "alert_teams_function" {
  filename         = data.archive_file.alert_teams_archive.output_path
  source_code_hash = data.archive_file.alert_teams_archive.output_base64sha256
  function_name    = var.alert_teams_function_name
  description      = "Forwards AWS GuardDuty findings to a Microsoft Teams channel."
  handler          = "alert_teams.lambda_handler"
  role             = aws_iam_role.alert_teams_role.arn

  runtime     = "python3.8"
  memory_size = 256
  timeout     = 30

  environment {
    variables = {
      ENVIRONMENT_LABEL  = var.environment_label
      SEVERITY_THRESHOLD = var.severity_threshold
      TEAMS_WEBHOOK_URL  = var.teams_webhook_url
    }
  }
}
