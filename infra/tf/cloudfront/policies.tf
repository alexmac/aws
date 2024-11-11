resource "aws_cloudfront_cache_policy" "public_content" {
  name        = "PublicContentCachePolicy"
  comment     = "caching for public content"
  default_ttl = 60
  max_ttl     = 86400
  min_ttl     = 10

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "public_content_request" {
  name    = "PublicContentOriginRequestPolicy"
  comment = "caching for public content"

  cookies_config {
    cookie_behavior = "none"
  }
  headers_config {
    header_behavior = "none"
  }
  query_strings_config {
    query_string_behavior = "all"
  }
}

resource "aws_cloudfront_response_headers_policy" "public_content_response" {
  name    = "PublicContentResponseHeaderPolicy"
  comment = "Security headers configuration for public content"

  security_headers_config {
    content_type_options {
      override = true # Prevents MIME type sniffing
    }
    frame_options {
      frame_option = "SAMEORIGIN" # Prevents clickjacking attacks
      override     = true
    }
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin" # Controls referrer information
      override        = true
    }
    strict_transport_security {
      access_control_max_age_sec = 31536000 # 1 year
      include_subdomains         = true      # Apply to all subdomains
      override                   = true
      preload                    = true      # Include in browser HSTS preload list
    }
  }

  server_timing_headers_config {
    enabled       = true
    sampling_rate = 100.0
  }

  # Remove server header to avoid information disclosure
  remove_headers_config {
    items {
      header = "Server"
    }
  }
}
