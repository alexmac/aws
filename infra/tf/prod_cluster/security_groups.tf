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

resource "aws_security_group" "alb_container_ingress" {
  name        = "prod-alb-ingress"
  description = "Allow ephemeral ports from ALB"
  vpc_id      = var.vpc_id
  tags = {
    Name = "prod-alb-ingress"
  }

  ingress {
    from_port       = 32768
    to_port         = 60999
    protocol        = "tcp"
    security_groups = [aws_security_group.prod_alb_sg.id]
  }
}
