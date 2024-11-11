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
    bucket  = module.alb_logs.bucket_id
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

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      message_body = "{}"
      status_code  = "400"
    }
  }
}

resource "aws_wafv2_web_acl_association" "internal_alb" {
  resource_arn = aws_lb.internal_alb.arn
  web_acl_arn  = aws_wafv2_web_acl.internal_alb.arn
}

resource "aws_wafv2_web_acl" "internal_alb" {
  name        = "prod-internal-alb-protection"
  description = "Basic WAF setup"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "reputation-rule"
    priority = 1

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-reputation-rule"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "common-rule"
    priority = 2

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-common-rule"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "waf-default-rule"
    sampled_requests_enabled   = false
  }
}

resource "aws_cloudwatch_log_group" "internal_alb" {
  name              = "aws-waf-logs-prod-internal-alb" # AWS quirk: must be prefixed with aws-waf-logs- or it will fail
  retention_in_days = 7
  kms_key_id        = var.kms_cloudtrailwatch_arn
}

resource "aws_wafv2_web_acl_logging_configuration" "internal_alb" {
  log_destination_configs = [aws_cloudwatch_log_group.internal_alb.arn]
  resource_arn            = aws_wafv2_web_acl.internal_alb.arn
}

resource "aws_cloudwatch_log_resource_policy" "internal_alb" {
  policy_document = data.aws_iam_policy_document.internal_alb.json
  policy_name     = "prod-internal-web-webacl-policy"
}

data "aws_iam_policy_document" "internal_alb" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.internal_alb.arn}:*"]
    condition {
      test     = "ArnLike"
      values   = ["arn:aws:logs:${var.region}:${var.account_id}:*"]
      variable = "aws:SourceArn"
    }
    condition {
      test     = "StringEquals"
      values   = [tostring(var.account_id)]
      variable = "aws:SourceAccount"
    }
  }
}
