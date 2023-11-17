output "dynamodb_unique_visitors_table_arn" {
  description = "The ARN of the DynamoDB table"
  value       = aws_dynamodb_table.unique_visitors_table.arn
}

output "table_name_unique_visitors" {
  value       = aws_dynamodb_table.unique_visitors_table.name
  description = "The name of the DynamoDB table"
}
