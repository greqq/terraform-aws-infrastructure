resource "aws_lambda_function" "visitor_counter_lambda" {
  function_name = var.function_name
  handler       = var.handler
  runtime       = "python3.11"

  s3_bucket = var.s3_bucket_lambda
  s3_key    = var.s3_key_lambda

  role          = aws_iam_role.lambda_role.arn
}

resource "aws_iam_role" "lambda_role" {
  name = var.role_name
  path = var.role_path

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}
