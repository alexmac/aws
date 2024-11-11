module "cacheserver_s3_bucket" {
  source      = "../modules/primitive/aws/s3_bucket"
  bucket_name = "${var.region}-cacheserver"
}

module "cacheserver_s3_bucket_lifecycle" {
  source    = "../modules/primitive/aws/7day_lifecycle"
  bucket_id = module.cacheserver_s3_bucket.bucket_id
}
