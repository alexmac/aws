variable "sns_arn" {
  type        = string
  description = "ARN of the SNS topic to send alarm notifications to"
}

variable "log_group_name" {
  type        = string
  description = "Name of the CloudWatch Log Group to monitor"
}

variable "name" {
  type        = string
  description = "Name for the metric filter and alarm"
}

variable "description" {
  type        = string
  description = "Description for the CloudWatch alarm"
}

variable "filter_pattern" {
  type        = string
  description = "CloudWatch Logs filter pattern to match log entries"
}
