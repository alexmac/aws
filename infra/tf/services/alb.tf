resource "aws_security_group" "cloudfront_https_access" {
  name        = "cloudfront-https-access"
  description = "Allow HTTPS inbound traffic from Cloudfront"
  vpc_id      = var.vpc_id
  tags = {
    Name = "cloudfront-https-access"
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = ["pl-82a045eb"]
  }
}

resource "aws_lb" "alb" {
  name               = "prod-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.cloudfront_https_access.id,
    var.prod_alb_sg,
  ]
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = false

  tags = {
    Name = "prod-alb"
  }
}

resource "aws_lb_listener" "prod_alb" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = "arn:aws:acm:us-west-2:${var.account_id}:certificate/c439b5cd-35d5-4052-a0f7-a09d7ebf3e0b"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cafetech_target_group.arn
  }
}