variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for the domain"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "Base domain name (e.g., lukamasa.com)"
  type        = string
}

variable "cloudfront_domain_name" {
  description = "CloudFront distribution domain name to point DNS to"
  type        = string
}

variable "certificate_validation_options" {
  description = "ACM certificate validation options from aws_acm_certificate"
  type = set(object({
    domain_name           = string
    resource_record_name  = string
    resource_record_type  = string
    resource_record_value = string
  }))
}
