resource "aws_cloudfront_origin_access_control" "my_oac" {
  name                              = "${var.bucket_name}.s3.${var.aws_region}.amazonaws.com"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_cache_policy" "my_cache_policy" {
  name    = var.environment_type == "prod" ? "Managed-CachingOptimized" : "Dev-CachingOptimized"
  comment = "Policy with caching enabled. Supports Gzip and Brotli compression."
  parameters_in_cache_key_and_forwarded_to_origin {

    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
    headers_config {
      header_behavior = "none"
    }

    cookies_config {
      cookie_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }

  min_ttl     = 1
  max_ttl     = 31536000
  default_ttl = 86400
}

resource "aws_cloudfront_distribution" "webflow_cloudfront_distribution" {
  enabled             = true
  comment             = var.cloudfront_comment
  default_root_object = "index.html"
  http_version        = "http2and3"
  is_ipv6_enabled     = true
  price_class         = var.price_class

  aliases = var.aliases

  origin {
    domain_name              = "${var.bucket_name}.s3.${var.aws_region}.amazonaws.com"
    origin_id                = "${var.bucket_name}.s3.${var.aws_region}.amazonaws.com"
    connection_attempts      = 3
    connection_timeout       = 10
    origin_access_control_id = aws_cloudfront_origin_access_control.my_oac.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.bucket_name}.s3.${var.aws_region}.amazonaws.com"

    compress               = true
    default_ttl            = 0
    max_ttl                = 0
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = aws_cloudfront_cache_policy.my_cache_policy.id
  }

  viewer_certificate {
    cloudfront_default_certificate = var.environment_type == "dev" ? true : false
    acm_certificate_arn      = var.environment_type == "prod" ? var.acm_certificate_arn : null
    ssl_support_method       = var.environment_type == "prod" ? "sni-only" : null
    minimum_protocol_version = var.environment_type == "prod" ? var.minimum_protocol_version : null
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}