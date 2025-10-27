output "certificate_arn" {
  description = "The ARN of the ACM certificate"
  value       = aws_acm_certificate.web_cert.arn
}

output "certificate_validation_options" {
  description = "Certificate validation DNS records for Cloudflare"
  value       = aws_acm_certificate.web_cert.domain_validation_options
}