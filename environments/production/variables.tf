# s3
variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  sensitive   = true
}

# cert
variable "domain_name" {
  description = "The domain name for the ACM certificate"
  type        = string
}

# cloudfront 

variable "aliases" {
  description = "CloudFront Aliases"
  type        = list(string)
  sensitive   = true
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


# dynamodb

variable "visitor_counter_table_name" {
  description = "Table name"
  type        = string
  sensitive   = true
}
variable "unique_visitor_table_name" {
  description = "Table name for unique visitors"
  type        = string
  sensitive   = true
}
variable "billing_mode" {
  description = "Billing mode for the table"
  type        = string
}


# dynamodb state

variable "state_table_name" {
  description = "Table name"
  type        = string
}

# s3 state

variable "state_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

# api_gateway

variable "api_name" {
  description = "Name for the API Gateway REST API"
  type        = string
}

variable "path_part" {
  description = "Path part for the API Gateway resource"
  type        = string
}

# variables.tf

variable "lambda_invoke_arn" {
  description = "The ARN to be used for invoking the lambda function from the API Gateway."
  type        = string
  default     = "default:arn"
}


#lambda 
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

# lambda alarms
variable "lambda_errors_alarm_name" {
  description = "Name of the Lambda errors alarm"
  type        = string
}

variable "lambda_errors_alarm_period" {
  description = "Period for Lambda errors alarm"
  type        = number
}

variable "lambda_errors_alarm_threshold" {
  description = "Threshold for Lambda errors alarm"
  type        = number
}

variable "lambda_errors_alarm_description" {
  description = "Description for Lambda errors alarm"
  type        = string
}

variable "lambda_alerts_topic_name" {
  description = "Name for the Lambda alerts topic"
  type        = string
}


variable "lambda_errors_email_endpoint" {
  description = "Email endpoint for Lambda errors"
  type        = string
}

variable "billing_alert_name" {
  description = "Name of the billing alert"
  type        = string
}

variable "billing_alert_period" {
  description = "Period for billing alert"
  type        = number
}

variable "billing_alert_threshold" {
  description = "Threshold for billing alert"
  type        = number
}

variable "billing_alert_description" {
  description = "Description for billing alert"
  type        = string
}

variable "billing_alerts_topic_name" {
  description = "Name for the billing alerts topic"
  type        = string
}

variable "billing_alerts_email_endpoint" {
  description = "Email endpoint for billing alerts"
  type        = string
}
