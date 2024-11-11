module "calambda" {
  source                  = "../modules/docker_lambda"
  account_id              = var.account_id
  region                  = var.region
  docker_image            = "staging/calambda:${local.calambda_docker_image}"
  lambda_name             = "calambda-ssh-host-key-signing"
  lambda_role_arn         = aws_iam_role.this.arn
  private_subnet_ids      = var.private_subnet_ids
  vpc_id                  = var.vpc_id
  kms_cloudtrailwatch_arn = var.kms_cloudtrailwatch_arn
  environment_variables = {
    KEY_ARN             = "arn:aws:kms:${var.region}:${var.account_id}:key/527415f9-fc26-4cb8-8c3e-c374f4099e9b"
    CERT_VALIDITY_HOURS = "12"
    DEBUG               = "false"
  }
}
