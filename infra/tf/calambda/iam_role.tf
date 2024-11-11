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
}

resource "aws_iam_policy" "ssh_host_key_signing" {
  name = "ssh-host-key-signing"
  path = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = "arn:aws:lambda:${var.region}:${var.account_id}:function:calambda-ssh-hostkey-signing"
      }
    ]
  })
}

resource "aws_iam_role_policy" "key_signing" {
  name = "KMSKeySigning"
  role = aws_iam_role.this.name
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

resource "aws_iam_role_policy" "lambda_env_vars" {
  name = "LambdaEnvVarKMS"
  role = aws_iam_role.this.name
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

resource "aws_iam_role_policy_attachments_exclusive" "inline_policies" {
  role_name = aws_iam_role.this.name
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
  ]
}

resource "aws_iam_role_policies_exclusive" "inline_policies" {
  role_name = aws_iam_role.this.name
  policy_names = [
    aws_iam_role_policy.key_signing.name,
    aws_iam_role_policy.lambda_env_vars.name,
  ]
}
