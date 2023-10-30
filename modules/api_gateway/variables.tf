variable "aws_region" {
  description = "AWS Region for the resources"
  type     = string 
}

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
  type = string
}

variable "output_api_endpoint_value" {
  description = "Endpoint value for the API"
  type        = string
}
