variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "bucket_id" {
  description = "ID of the S3 bucket"
  type        = string
}

variable "bucket_arn" {
  description = "ARN of the S3 bucket"
  type        = string
}

output "cloudtrail_policy_json" {
  value = data.aws_iam_policy_document.cloudtrail_policy.json
}
