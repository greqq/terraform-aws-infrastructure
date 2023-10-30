output "distribution_id" {
  value       = aws_cloudfront_distribution.webflow_cloudfront_distribution.id
  description = "The ID of the CloudFront distribution."
}

output "distribution_domain_name" {
  value       = aws_cloudfront_distribution.webflow_cloudfront_distribution.domain_name
  description = "The domain name of the CloudFront distribution."
}
