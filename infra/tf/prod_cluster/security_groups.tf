resource "aws_security_group" "prod_sg" {
  name        = "prod-sg"
  description = "Traffic from prod"
  vpc_id      = var.vpc_id
  tags = {
    Name = "prod-sg"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "prod_alb_sg" {
  name        = "prod-alb-sg"
  description = "Traffic from the prod SG"
  vpc_id      = var.vpc_id
  tags = {
    Name = "prod-alb-sg"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "prod_internal_alb_sg" {
  name        = "prod-internal-alb-sg"
  description = "Traffic from the internal prod SG"
  vpc_id      = var.vpc_id
  tags = {
    Name = "prod-internal-alb-sg"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_container_ingress" {
  name        = "prod-alb-ingress"
  description = "Allow ephemeral ports from ALB"
  vpc_id      = var.vpc_id
  tags = {
    Name = "prod-alb-ingress"
  }

  ingress {
    from_port = 32768
    to_port   = 60999
    protocol  = "tcp"
    security_groups = [
      aws_security_group.prod_alb_sg.id,
      aws_security_group.prod_internal_alb_sg.id,
    ]
  }
}

resource "aws_security_group" "prod_xray" {
  name        = "prod-xray-ingress"
  description = "Allow host to send XRay traces to itself"
  vpc_id      = var.vpc_id
  tags = {
    Name = "prod-xray-ingress"
  }

  ingress {
    from_port       = 40000
    to_port         = 40000
    protocol        = "udp"
    security_groups = [aws_security_group.prod_sg.id]
  }
  ingress {
    from_port       = 40000
    to_port         = 40000
    protocol        = "tcp"
    security_groups = [aws_security_group.prod_sg.id]
  }
}

resource "aws_security_group" "prod_otel" {
  name        = "prod-otel-ingress"
  description = "Allow host to send Open Telemetry metrics to itself"
  vpc_id      = var.vpc_id
  tags = {
    Name = "prod-otel-ingress"
  }

  ingress {
    from_port       = 4317
    to_port         = 4318
    protocol        = "tcp"
    security_groups = [aws_security_group.prod_sg.id]
  }
}


resource "aws_security_group" "prod_https" {
  name        = "prod-https-ingress"
  description = "Allow HTTPS ingress from a prod machine"
  vpc_id      = var.vpc_id
  tags = {
    Name = "prod-https-ingress"
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.prod_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}