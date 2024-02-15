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

output "dev_api_invoke_url" {
  description = "The invoke URL for the development stage of the API Gateway"
  value       = "https://${module.api_gateway.rest_api_id}.execute-api.${var.aws_region}.amazonaws.com/dev/${var.path_part}"
  sensitive   = true
}

output "lambda_function_name" {
  description = "Name of the lambda function"
  value       = module.lambda.lambda_function_name
  sensitive   = true
}

