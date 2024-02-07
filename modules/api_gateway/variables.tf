variable "api_name" {
  description = "Name for the API Gateway REST API"
  type        = string
}

variable "path_part" {
  description = "Path part for the API Gateway resource"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "The ARN to be used for invoking the lambda function from the API Gateway."
  type        = string
}


variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "environment_type" {
  description = "The deployment environment (e.g., 'dev', 'prod')"
  type        = string
  default     = "prod"
}

