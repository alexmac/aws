resource "aws_cloudfront_distribution" "distro" {
  enabled         = true
  is_ipv6_enabled = false
  http_version    = "http2"

  aliases = [
    "0xcafe.tech",
    "www.0xcafe.tech",
  ]

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:${var.account_id}:certificate/d900118a-5f6c-4239-916c-2abf4a761d83"
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  origin {
    domain_name = "alb.0xcafe.tech"
    origin_id   = "ALBOrigin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "ALBOrigin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET", "HEAD", "OPTIONS", "PUT", "PATCH", "POST", "DELETE"
    ]
    cached_methods = [
      "GET", "HEAD"
    ]
    compress                   = true
    cache_policy_id            = aws_cloudfront_cache_policy.public_content.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.public_content_request.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.public_content_response.id
  }
}
