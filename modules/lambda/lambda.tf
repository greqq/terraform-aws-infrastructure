# ============================================================================
# LAMBDA MODULE - Serverless Function
# ============================================================================
# This module creates a Lambda function for the visitor counter logic
#
# VISITOR COUNTER LOGIC (Python):
#   1. Receive API call from frontend
#   2. Extract visitor IP address from request
#   3. Hash IP for privacy (store hash, not actual IP)
#   4. Check if hash exists in UniqueVisitors table
#   5. If new: Increment VisitorCounter, add hash to UniqueVisitors
#   6. Return current count to frontend
#
# COST CALCULATION:
#   - 1000 visitors/month × 100ms execution = $0.002
#   - Effectively free for personal resume site
#
# ============================================================================

# ============================================================================
# LAMBDA FUNCTION
# ============================================================================
# Serverless function that processes visitor counter requests
# ============================================================================

resource "aws_lambda_function" "visitor_counter_lambda" {
  function_name = var.function_name # "incrementCounter"
  handler       = var.handler       # "lambda_function.lambda_handler"
  runtime       = "python3.11"      # Python version

  # Code location in S3 (ZIP file)
  s3_bucket = var.s3_bucket_lambda # "terraform-config-cloud-resume"
  s3_key    = var.s3_key_lambda    # "object.zip"

  # IAM role that defines what AWS services Lambda can access
  role = aws_iam_role.lambda_role.arn

  # Environment variables accessible in Lambda code
  # Python: os.environ['VISITOR_COUNTER_TABLE']
  environment {
    variables = {
      ENVIRONMENT_TYPE      = var.environment_type           # "prod" or "dev"
      VISITOR_COUNTER_TABLE = var.visitor_counter_table_name # "VisitorCounter"
      UNIQUE_VISITOR_TABLE  = var.unique_visitor_table_name  # "UniqueVisitors"
    }
  }

  # Optional performance tuning (not set = defaults)
  # memory_size = 128  # MB (default: 128, max: 10240)
  # timeout     = 3    # seconds (default: 3, max: 900)
}

# ============================================================================
# IAM ROLE - Lambda Permissions
# ============================================================================
# Defines WHAT this Lambda function is allowed to do
# Uses "assume role policy" to allow Lambda service to use this role
# ============================================================================

resource "aws_iam_role" "lambda_role" {
  name_prefix = "${var.function_name}-" # Creates unique name: "incrementCounter-xxxxx"
  path        = var.role_path           # "/service-role/"

  # Trust policy: Allows Lambda service to assume this role
  assume_role_policy = templatefile("../../modules/lambda/lambda_policy.tpl", {
    service = "lambda.amazonaws.com"
  })
}

# ============================================================================
# IAM POLICY ATTACHMENT - DynamoDB Access
# ============================================================================
# Grants Lambda full access to DynamoDB tables
# ============================================================================

resource "aws_iam_role_policy_attachment" "dynamodb_fullaccess" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}
