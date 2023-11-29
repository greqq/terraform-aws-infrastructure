resource "aws_lambda_function" "visitor_counter_lambda" {
  function_name = var.function_name
  handler       = var.handler
  runtime       = "python3.11"

  s3_bucket = var.s3_bucket_lambda
  s3_key    = var.s3_key_lambda

  role          = aws_iam_role.lambda_role.arn
  code_signing_config_arn = aws_lambda_code_signing_config.lambda_sign.arn
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

resource "aws_signer_signing_profile" "lambda_sign" {
  name = "LambdaSign"
  platform_id = "AWSLambda-SHA384-ECDSA"
}

resource "aws_lambda_code_signing_config" "lambda_sign" {
  allowed_publishers {
    signing_profile_version_arns = [aws_signer_signing_profile.lambda_sign.version_arn]
  }

  policies {
    untrusted_artifact_on_deployment = "Enforce" 
  }
}

