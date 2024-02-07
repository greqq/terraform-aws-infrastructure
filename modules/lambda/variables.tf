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

variable "environment_type" {
  description = "The deployment environment (e.g., 'dev', 'prod')"
  type        = string
  default     = "prod"
}

variable "visitor_counter_table_name" {
  description = "The name of the DynamoDB table for visitor counter"
  type        = string
  default     = "VisitorCounter"
}

variable "unique_visitor_table_name" {
  description = "The name of the DynamoDB table for unique visitors"
  type        = string
  default     = "UniqueVisitors"
}


