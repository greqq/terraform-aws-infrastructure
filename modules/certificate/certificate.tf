# ============================================================================
# CERTIFICATE MODULE - SSL/TLS Certificate
# ============================================================================
# This module creates an SSL certificate for HTTPS
# using AWS Certificate Manager (ACM)
# ============================================================================

resource "aws_acm_certificate" "web_cert" {
  domain_name       = var.domain_name # "lukamasa.com" (primary domain)
  
  # Subject Alternative Names: Additional domains covered by this certificate
  # This allows the same certificate to work for both:
  #   - lukamasa.com
  #   - www.lukamasa.com
  subject_alternative_names = ["www.${var.domain_name}"]  # ["www.lukamasa.com"]
  
  validation_method = "DNS" # Verify ownership via DNS record

  # Lifecycle: Create new certificate before destroying old one
  # Prevents downtime during certificate rotation
  lifecycle {
    create_before_destroy = true
  }

  # Tags for organization and cost tracking
  tags = {
    Name        = var.domain_name
    Environment = "production"
  }
}
