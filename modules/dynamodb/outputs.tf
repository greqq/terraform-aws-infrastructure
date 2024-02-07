output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table"
  value       = aws_dynamodb_table.visitor_counter_table.arn
}

output "visitor_counter_table_name" {
  value       = aws_dynamodb_table.visitor_counter_table.name
  description = "The name of the DynamoDB table"
}
