variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "handler" {
  description = "Handler for the Lambda function"
  type        = string
}

variable "s3_bucket_lambda" {
  description = "S3 bucket where the Lambda function code resides"
  type        = string
}

variable "s3_key_lambda" {
  description = "S3 key for the Lambda function code"
  type        = string
}

variable "role_name" {
  description = "Name for the IAM role"
  type        = string
}

variable "role_path" {
  description = "Path for the IAM role"
  type        = string
}
