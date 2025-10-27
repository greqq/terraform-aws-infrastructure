output "validation_record_fqdns" {
  description = "FQDNs of the DNS validation records created"
  value       = [for record in cloudflare_record.cert_validation : record.hostname]
}

output "apex_domain_record" {
  description = "FQDN of the apex domain DNS record"
  value       = cloudflare_record.apex_domain.hostname
}

output "www_domain_record" {
  description = "FQDN of the www subdomain DNS record"
  value       = cloudflare_record.www_subdomain.hostname
}
