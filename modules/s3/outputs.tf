output "bucket_arn" {
  value       = aws_s3_bucket.webflow_projects_assets.arn
  description = "The ARN of the bucket."
}

output "bucket_id" {
  value       = aws_s3_bucket.webflow_projects_assets.id
  description = "The ID of the bucket."
}

output "bucket_name" {
  value       = aws_s3_bucket.webflow_projects_assets.bucket
  description = "The name of the S3 bucket"
}

