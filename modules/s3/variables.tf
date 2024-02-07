variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  type        = string
}

variable "environment_type" {
  description = "The deployment environment (e.g., 'dev', 'prod')"
  type        = string
  default     = "prod"
}
