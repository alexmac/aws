resource "aws_security_group" "calambda_sg" {
  name        = "lambda-calambda"
  description = "Traffic from calambda"
  vpc_id      = var.vpc_id
  tags = {
    Name = "lambda-calambda"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lambda_function" "calambda" {
  function_name = "calambda-ssh-host-key-signing"

  role = aws_iam_role.this.arn

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.calambda_sg.id]
  }

  architectures = ["arm64"]
  package_type  = "Image"
  image_uri     = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/staging/calambda:${local.calambda_docker_image}"
  timeout       = 60

  environment {
    variables = {
      KEY_ARN             = "arn:aws:kms:${var.region}:${var.account_id}:key/527415f9-fc26-4cb8-8c3e-c374f4099e9b"
      CERT_VALIDITY_HOURS = 12
      DEBUG               = "false"
    }
  }
}
