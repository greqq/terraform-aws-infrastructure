output "sns_topic_arn" {
  description = "The ARN of the SNS topic for lambda error alerts."
  value       = aws_sns_topic.lambda_alerts.arn
}
