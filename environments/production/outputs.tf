output "s3_bucket_name" {
  value     = module.s3.bucket_name
  sensitive = true
}

output "cloudfront_distribution_id" {
  value     = module.cloudfront.distribution_id
  sensitive = true
}

output "dynamodb_table_name" {
  value     = module.dynamodb.visitor_counter_table_name
  sensitive = true
}

output "certificate_arn" {
  description = "The ARN of the ACM certificate"
  value       = module.certificate.certificate_arn
  sensitive   = true
}