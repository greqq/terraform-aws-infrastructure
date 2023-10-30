output "s3_bucket_name" {
  value     = module.s3.bucket_name
  sensitive = true
}

output "cloudfront_distribution_id" {
  value     = module.cloudfront.distribution_id
  sensitive = true
}

output "dynamodb_table_name" {
  value     = module.dynamodb.table_name
  sensitive = true
}

output "s3_bucket_arn" {
  value       = module.s3_state.s3_bucket_arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name_terraform_lock" {
  value       = module.dynamodb_state.dynamodb_table_name
  description = "The name of the DynamoDB table"
}
