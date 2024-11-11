module "alb_logs" {
  source                 = "../modules/primitive/aws/s3_bucket"
  bucket_name            = "cafetech-alb-logs-prod-alb"
  override_bucket_policy = true
}

module "alb_logs_cloudtrail_policy" {
  source     = "../modules/primitive/aws/s3_cloudtrail_policy"
  account_id = var.account_id
  bucket_id  = module.alb_logs.bucket_id
  bucket_arn = module.alb_logs.bucket_arn
}

module "alb_logs_bucket_policy" {
  source     = "../modules/primitive/aws/s3_bucket_policy"
  bucket_id  = module.alb_logs.bucket_id
  bucket_arn = module.alb_logs.bucket_arn
  additional_policy_documents = [
    module.alb_logs_cloudtrail_policy.cloudtrail_policy_json
  ]
}

module "alb_logs_lifecycle" {
  source    = "../modules/primitive/aws/7day_lifecycle"
  bucket_id = module.alb_logs.bucket_id
}
