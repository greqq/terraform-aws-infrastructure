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

variable "lambda_alerts_topic_policy" {
  description = "Policy for the Lambda alerts topic"
  type        = string
}

variable "lambda_errors_email_endpoint" {
  description = "Email endpoint for Lambda errors"
  type        = string
}

variable "function_name" {
  description = "Name of the Lambda function"
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

variable "billing_alerts_topic_policy" {
  description = "Policy for the billing alerts topic"
  type        = string
}

variable "billing_alerts_email_endpoint" {
  description = "Email endpoint for billing alerts"
  type        = string
}
