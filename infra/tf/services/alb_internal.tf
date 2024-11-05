resource "aws_lb" "internal_alb" {
  name               = "prod-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    var.packer_fargate_https_sg,
    var.prod_https_sg,
    var.prod_internal_alb_sg,
    var.tailscale_https_access_sg,
  ]
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = true

  desync_mitigation_mode = "strictest"

  drop_invalid_header_fields = true

  enable_http2 = true

  ip_address_type = "ipv4"

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    enabled = true
  }

  tags = {
    Name = "prod-internal-alb"
  }
}

resource "aws_lb_listener" "internal_alb" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = "arn:aws:acm:${var.region}:${var.account_id}:certificate/c439b5cd-35d5-4052-a0f7-a09d7ebf3e0b"

  # default_action {
  #   type = "fixed-response"

  #   fixed_response {
  #     content_type = "application/json"
  #     message_body = "{}"
  #     status_code  = "400"
  #   }
  # }
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cacheserver_target_group.arn
  }
}
