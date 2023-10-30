output "visitor_counter_lambda_invoke_arn" {
  value = aws_lambda_function.visitor_counter_lambda.invoke_arn
  description = "The ARN to be used for invoking the visitor counter lambda function from the API Gateway."
}
