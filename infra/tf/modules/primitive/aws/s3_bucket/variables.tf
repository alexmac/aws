variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

variable "add_random_suffix" {
  type        = bool
  description = "Add a random suffix to the bucket name"
  default     = true
}

variable "force_destroy" {
  type        = bool
  description = "Allow destruction of non-empty bucket"
  default     = false
}
variable "versioning_enabled" {
  type        = bool
  description = "Enable versioning on the bucket"
  default     = true
}

variable "encryption_enabled" {
  type        = bool
  description = "Enable server-side encryption"
  default     = true
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of KMS key to use for encryption"
  default     = null
}

variable "block_public_access" {
  type        = bool
  description = "Enable block public access settings"
  default     = true
}

variable "override_bucket_policy" {
  description = "Whether to override the default bucket policy"
  type        = bool
  default     = false
}

output "bucket_id" {
  value       = aws_s3_bucket.this.id
  description = "The name of the bucket"
}

output "bucket_arn" {
  value       = aws_s3_bucket.this.arn
  description = "The ARN of the bucket"
}
