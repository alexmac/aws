resource "aws_security_group" "this" {
  name        = "lambda-${var.lambda_name}"
  description = "Traffic from lambda: ${var.lambda_name}"
  vpc_id      = var.vpc_id
  tags = {
    Name = "lambda-${var.lambda_name}"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = 7
}

resource "aws_lambda_function" "this" {
  function_name = var.lambda_name

  role = var.lambda_role_arn

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.this.id]
  }

  logging_config {
    log_format = "Text"
    log_group  = aws_cloudwatch_log_group.this.name
  }

  timeout = var.timeout

  architectures = ["arm64"]
  package_type  = "Image"
  image_uri     = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.docker_image}"
}
