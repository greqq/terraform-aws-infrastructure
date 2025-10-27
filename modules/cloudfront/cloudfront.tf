# ============================================================================
# CLOUDFRONT MODULE - Content Delivery Network (CDN)
# ============================================================================
# This module creates a CloudFront distribution for global content delivery
#
# ARCHITECTURE:
#   User (Global) → CloudFront Edge Location → S3 Origin (us-east-1)
#
# ============================================================================

# ============================================================================
# ORIGIN ACCESS CONTROL (OAC)
# ============================================================================
# Allows CloudFront to access private S3 bucket securely
# Result: Only CloudFront can access bucket, direct URLs blocked
# ============================================================================

resource "aws_cloudfront_origin_access_control" "my_oac" {
  name                              = "${var.bucket_name}.s3.${var.aws_region}.amazonaws.com"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always" # Always sign requests to S3
  signing_protocol                  = "sigv4"  # AWS Signature Version 4
}

# ============================================================================
# CACHE POLICY
# ============================================================================
# Controls what gets cached and for how long
# Compression: Reduces file sizes (faster downloads, lower bandwidth costs)

# ============================================================================

resource "aws_cloudfront_cache_policy" "my_cache_policy" {
  name    = var.environment_type == "prod" ? "Managed-CachingOptimized" : "Dev-CachingOptimized"
  comment = "Policy with caching enabled. Supports Gzip and Brotli compression."
  parameters_in_cache_key_and_forwarded_to_origin {

    enable_accept_encoding_brotli = true # Modern compression (better than Gzip)
    enable_accept_encoding_gzip   = true # Standard compression (broad support)

    headers_config {
      header_behavior = "none" # Don't include headers in cache key
    }

    cookies_config {
      cookie_behavior = "none" # Don't include cookies in cache key
    }

    query_strings_config {
      query_string_behavior = "none" # Don't include query params in cache key
    }
  }

  min_ttl     = 1        # Minimum cache time: 1 second
  max_ttl     = 31536000 # Maximum cache time: 1 year (365 days)
  default_ttl = 86400    # Default cache time: 1 day (24 hours)
}

# ============================================================================
# CLOUDFRONT DISTRIBUTION
# ============================================================================
# The main CDN configuration
# This creates a globally distributed network of edge servers
# Random domain assigned (e.g., d2f6xchafpiznf.cloudfront.net)
# Custom domain (lukamasa.com) mapped via Cloudflare DNS CNAME
# ============================================================================

resource "aws_cloudfront_distribution" "webflow_cloudfront_distribution" {
  enabled             = true
  comment             = var.cloudfront_comment
  default_root_object = "index.html"           # Serve this file for root requests
  http_version        = "http2and3"            # Support HTTP/2 and HTTP/3 (QUIC)
  is_ipv6_enabled     = true                   # Support IPv6 addresses


  # PriceClass_100: US, Canada, Europe (cheapest)
  price_class = var.price_class # "PriceClass_100"

  # Custom domain names (requires SSL certificate)
  # Must match certificate domains exactly
  aliases = var.aliases # ["lukamasa.com"]

  # ============================================================================
  # ORIGIN - Where CloudFront Gets Content
  # ============================================================================
  # Points to S3 bucket in us-east-1
  # Uses OAC for secure access (no public bucket needed)
  # ============================================================================

  origin {
    domain_name              = "${var.bucket_name}.s3.${var.aws_region}.amazonaws.com"
    origin_id                = "${var.bucket_name}.s3.${var.aws_region}.amazonaws.com"
    connection_attempts      = 3  # Retry up to 3 times if origin fails
    connection_timeout       = 10 # Wait 10 seconds before timing out
    origin_access_control_id = aws_cloudfront_origin_access_control.my_oac.id
  }

  # ============================================================================
  # CACHE BEHAVIOR - How to Handle Requests
  # ============================================================================
  # Defines caching rules and request handling
  # ============================================================================

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"] # Only allow read operations
    cached_methods   = ["GET", "HEAD"] # Cache these methods
    target_origin_id = "${var.bucket_name}.s3.${var.aws_region}.amazonaws.com"

    compress               = true                # Compress responses (Gzip/Brotli)
    default_ttl            = 0                   # Don't cache by default (controlled via CI/CD invalidations)
    max_ttl                = 0                   # Maximum cache time
    viewer_protocol_policy = "redirect-to-https" # Force HTTPS (HTTP → HTTPS redirect)
    cache_policy_id        = aws_cloudfront_cache_policy.my_cache_policy.id
  }

  # ============================================================================
  # SSL/TLS CERTIFICATE
  # ============================================================================
  # Production: Uses custom ACM certificate for lukamasa.com
  # Development: Uses CloudFront default certificate (*.cloudfront.net)
  # ============================================================================

  viewer_certificate {
    cloudfront_default_certificate = var.environment_type == "dev" ? true : false
    acm_certificate_arn            = var.environment_type == "prod" ? var.acm_certificate_arn : null
    ssl_support_method             = var.environment_type == "prod" ? "sni-only" : null                   # Free SSL via SNI
    minimum_protocol_version       = var.environment_type == "prod" ? var.minimum_protocol_version : null # TLSv1.2_2021
  }

  # ============================================================================
  # GEOGRAPHIC RESTRICTIONS
  # ============================================================================
  # Can restrict content by country (e.g., GDPR compliance, licensing)
  # ============================================================================

  restrictions {
    geo_restriction {
      restriction_type = "none" # No geographic restrictions
      # To restrict: "whitelist" or "blacklist"
      # locations = ["US", "CA", "GB"]
    }
  }
}