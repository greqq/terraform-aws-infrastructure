resource "aws_cloudfront_distribution" "webflow_cloudfront_distribution" {
  enabled             = true
  comment             = var.cloudfront_comment
  default_root_object = "index.html"
  http_version        = "http2and3"
  is_ipv6_enabled     = true
  price_class         = var.price_class

  aliases = var.aliases

  origin {
    domain_name              = var.origin_domain_name
    origin_id                = var.origin_id
    connection_attempts      = 3
    connection_timeout       = 10
    origin_access_control_id = var.origin_access_control_id
  }

default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.target_origin_id

    compress               = true
    default_ttl            = 0
    max_ttl                = 0
    viewer_protocol_policy = "redirect-to-https"

    /* forwarded_values { 
      query_string = false

      cookies {
        forward = "none"
      }
    } */

    cache_policy_id = var.cache_policy_id
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = var.minimum_protocol_version
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
