# ============================================================================
# CLOUDFLARE DNS MODULE - Automated DNS Management
# ============================================================================
# This module manages Cloudflare DNS records for:
#   1. ACM certificate validation (automatic verification)
#   2. Domain routing to CloudFront CDN
#
# WHAT IT DOES:
#   - Creates DNS validation records for AWS ACM certificate
#   - Creates CNAME records pointing domain(s) to CloudFront
#   - Automates the manual Cloudflare DNS steps
#
# REQUIREMENTS:
#   - Cloudflare API token with DNS edit permissions
#   - Zone ID for lukamasa.com
# ============================================================================

# ============================================================================
# ACM CERTIFICATE VALIDATION RECORDS
# ============================================================================
# Creates DNS records required by AWS to validate domain ownership
# ACM provides specific CNAME values, we create them in Cloudflare
# Once DNS propagates, ACM automatically validates the certificate
#
# IMPORTANT: 
#   - Proxy must be OFF (DNS-only, grey cloud) for validation to work
#   - These records are only for validation, not traffic routing
#   - for_each loops through all validation options (one per domain/SAN)
# ============================================================================

resource "cloudflare_record" "cert_validation" {
  for_each = {
    for dvo in var.certificate_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = var.cloudflare_zone_id
  name    = trimsuffix(each.value.name, ".")  # Remove trailing dot if present
  content = trimsuffix(each.value.record, ".")
  type    = each.value.type
  ttl     = 60     # 1 minute TTL (fast propagation)
  proxied = false  # CRITICAL: Must be DNS-only for ACM validation
  
  comment = "ACM certificate validation for ${each.key}"
}

# ============================================================================
# CLOUDFRONT ROUTING - APEX DOMAIN (lukamasa.com)
# ============================================================================
# Points lukamasa.com to CloudFront distribution
# Uses CNAME to route traffic through CloudFront CDN
# Note: Cloudflare proxy is disabled (grey cloud)
# ============================================================================

resource "cloudflare_record" "apex_domain" {
  zone_id = var.cloudflare_zone_id
  name    = var.domain_name                  # "lukamasa.com"
  content = var.cloudfront_domain_name       # "d2f6xchafpiznf.cloudfront.net"
  type    = "CNAME"
  ttl     = 1      # Auto TTL (Cloudflare manages)
  proxied = false  # DNS-only (grey cloud) - CloudFront handles SSL
  
  comment = "Routes to CloudFront CDN for website hosting"
}

# ============================================================================
# CLOUDFRONT ROUTING - WWW SUBDOMAIN (www.lukamasa.com)
# ============================================================================
# Points www.lukamasa.com to CloudFront distribution
# Same CloudFront distribution serves both apex and www
# ============================================================================

resource "cloudflare_record" "www_subdomain" {
  zone_id = var.cloudflare_zone_id
  name    = "www.${var.domain_name}"         # "www.lukamasa.com"
  content = var.cloudfront_domain_name       # "d2f6xchafpiznf.cloudfront.net"
  type    = "CNAME"
  ttl     = 1      # Auto TTL
  proxied = false  # DNS-only - CloudFront handles everything
  
  comment = "Routes www subdomain to CloudFront CDN"
}
