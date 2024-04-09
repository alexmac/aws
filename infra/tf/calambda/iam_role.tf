module "calambda_assume_role" {
  source     = "../modules/iams/assume_role"
  account_id = var.account_id
  services   = ["lambda.amazonaws.com"]
}

data "aws_kms_key" "lambda" {
  key_id = "alias/aws/lambda"
}

resource "aws_iam_role" "this" {
  name               = "calambda"
  assume_role_policy = module.calambda_assume_role.policy_document
  path               = "/"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
  ]

  inline_policy {
    name = "KMSKeySigning"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "kms:Sign",
            "kms:GetPublicKey",
          ]
          Resource = "arn:aws:kms:${var.region}:${var.account_id}:key/527415f9-fc26-4cb8-8c3e-c374f4099e9b"
        }
      ]
    })
  }

  inline_policy {
    name = "LambdaEnvVarKMS"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "kms:Decrypt",
          ]
          Resource = data.aws_kms_key.lambda.arn
        }
      ]
    })
  }
}
