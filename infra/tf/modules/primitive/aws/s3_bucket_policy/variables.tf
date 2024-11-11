variable "bucket_id" {
  description = "The ID of the S3 bucket to apply the policy to"
  type        = string
}

variable "bucket_arn" {
  description = "The ARN of the S3 bucket"
  type        = string
}

variable "additional_policy_documents" {
  description = "List of additional IAM policy documents that can be combined with the default SSL-only policy"
  type        = list(string)
  default     = null
} 