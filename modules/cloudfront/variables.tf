variable "aliases" {
  description = "CloudFront Aliases"
  type        = list(string)
}

variable "acm_certificate_arn" {
  description = "ACM Certificate ARN"
  type        = string
}

variable "cloudfront_comment" {
  description = "Comment for the CloudFront distribution"
  type        = string
}

variable "price_class" {
  description = "Price class for the CloudFront distribution"
  type        = string
}

variable "minimum_protocol_version" {
  description = "Minimum protocol version for the viewer certificate"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "environment_type" {
  description = "The deployment environment (e.g., 'dev', 'prod')"
  type        = string
}