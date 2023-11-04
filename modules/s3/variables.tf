variable "aws_region" {
  description = "AWS Region"
  type        = string
}


variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  type        = string
}

variable "account_id" {
  description = "The AWS Account ID"
  type        = string
}
