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

  role = "arn:aws:iam::${var.account_id}:role/calambda"

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.calambda_sg.id]
  }

  architectures = ["arm64"]
  package_type  = "Image"
  image_uri     = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/staging/calambda:${local.calambda_docker_image}"
  timeout       = 60
}
