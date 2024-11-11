output "lifecycle_configuration_id" {
  description = "ID of the lifecycle configuration"
  value       = aws_s3_bucket_lifecycle_configuration.this.id
} 