resource "aws_acm_certificate" "web_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"
}
