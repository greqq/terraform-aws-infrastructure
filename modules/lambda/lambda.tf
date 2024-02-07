resource "aws_lambda_function" "visitor_counter_lambda" {
  function_name = var.function_name
  handler       = var.handler
  runtime       = "python3.11"

  s3_bucket = var.s3_bucket_lambda
  s3_key    = var.s3_key_lambda

  role = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      ENVIRONMENT_TYPE      = var.environment_type
      VISITOR_COUNTER_TABLE = var.visitor_counter_table_name
      UNIQUE_VISITOR_TABLE  = var.unique_visitor_table_name
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  # name = var.role_name
  path = var.role_path

  assume_role_policy = templatefile("../../modules/lambda/lambda_policy.tpl", {
    service = "lambda.amazonaws.com"
  })
}