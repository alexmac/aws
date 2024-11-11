resource "aws_athena_workgroup" "primary" {
  description   = null
  force_destroy = false
  name          = "primary"
  state         = "ENABLED"
  tags          = {}
  tags_all      = {}
  configuration {
    bytes_scanned_cutoff_per_query     = 0
    enforce_workgroup_configuration    = false
    execution_role                     = null
    publish_cloudwatch_metrics_enabled = true
    requester_pays_enabled             = false
    engine_version {
      selected_engine_version = "AUTO"
    }
    result_configuration {
      expected_bucket_owner = null
      output_location       = null
      encryption_configuration {
        encryption_option = "SSE_S3"
        kms_key_arn       = null
      }
    }
  }
}