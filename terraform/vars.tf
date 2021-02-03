variable "profile" {
  description = "The name of the profile to use for AWS operations."
  type        = string
}

variable "region" {
  description = "The region that the resources will be applied in."
  type        = string
}

variable "alert_teams_function_name" {
  description = "The name for the alert teams lambda function."
  type        = string
}

variable "environment_label" {
  description = "A label describing the environment/stack that the resources will be applied in."
  type        = string
}

variable "severity_threshold" {
  description = "The minimum severity level of findings to alert on."
  type        = string
}

variable "teams_webhook_url" {
  description = "Incoming webhook URL for Microsoft Teams."
  type        = string
}

variable "cloudwatch_expire_days" {
  description = "Expiration period for CloudWatch log events."
  type        = number
  default     = 30
}
