data "archive_file" "alert_teams_archive" {
  type        = "zip"
  output_path = "${path.module}/../functions/alert_teams.zip"
  source_file = "${path.module}/../functions/alert_teams.py"
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
