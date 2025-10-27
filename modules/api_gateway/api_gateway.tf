# ============================================================================
# API GATEWAY MODULE - Visitor Counter API
# ============================================================================
# This module creates a REST API endpoint for the visitor counter functionality
#
# ARCHITECTURE:
#   Browser → API Gateway → Lambda → DynamoDB
#
# ENDPOINTS:
#   POST    /visitCount  → Increments counter and returns count (Lambda integration)
#   OPTIONS /visitCount  → CORS preflight check (MOCK integration - no Lambda call)
#
# CORS CONFIGURATION:
#   Production: Only allows https://lukamasa.com
#   Development: Allows all origins (*)
#
# REQUEST FLOW:
#   1. Browser detects cross-origin request
#   2. Browser sends OPTIONS preflight (automatic)
#   3. API Gateway responds with CORS headers (MOCK - instant)
#   4. Browser sends actual POST request
#   5. API Gateway forwards to Lambda (AWS_PROXY mode)
#   6. Lambda processes and returns response
#   7. API Gateway adds CORS headers and returns to browser
#
# KEY CONCEPTS:
#   - AWS_PROXY: Lambda receives full HTTP request and controls response
#   - MOCK: Returns immediate response without calling backend (used for OPTIONS)
#   - Deployment: Changes require new deployment to take effect
#   - Stage: Environment version (prod/dev) - becomes part of URL
# ============================================================================

# ============================================================================
# API GATEWAY REST API
# ============================================================================
# Creates the main API Gateway REST API instance
# Type: REGIONAL (deployed in us-east-1, not edge-optimized)
# Generates random ID like "hajo8bobtk" which becomes part of the URL
# ============================================================================

resource "aws_api_gateway_rest_api" "visitor_counter_api" {
  name        = var.api_name
  description = "API for visitor counter"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# ============================================================================
# API RESOURCE (URL PATH)
# ============================================================================
# Creates the /visitCount path under the root resource
# Final URL: https://{api-id}.execute-api.{region}.amazonaws.com/{stage}/visitCount
# ============================================================================

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  parent_id   = aws_api_gateway_rest_api.visitor_counter_api.root_resource_id
  path_part   = var.path_part # "visitCount"
}

# ============================================================================
# POST METHOD - Main API Endpoint
# ============================================================================
# Accepts POST requests from the frontend to increment visitor counter
# Authorization: NONE (public API, CORS provides domain restriction)
# ============================================================================

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "POST"
  authorization = "NONE" # Public API. Other options: AWS_IAM, COGNITO_USER_POOLS, CUSTOM
}

# ============================================================================
# LAMBDA INTEGRATION (AWS_PROXY)
# ============================================================================
# Routes POST requests to Lambda function
# AWS_PROXY mode: Lambda receives full HTTP request and returns full HTTP response
# - No request/response transformations by API Gateway
# - Lambda controls status codes, headers, body format
# integration_http_method: Always POST when calling Lambda (regardless of client method)
# ============================================================================

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id      = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id      = aws_api_gateway_resource.resource.id
  http_method      = aws_api_gateway_method.method.http_method
  content_handling = "CONVERT_TO_TEXT"

  integration_http_method = "POST"      # How API Gateway calls Lambda (always POST)
  type                    = "AWS_PROXY" # Proxy mode - Lambda gets full request context
  uri                     = var.lambda_invoke_arn
}

# ============================================================================
# DEPLOYMENT
# ============================================================================
# Creates a "snapshot" of the API configuration
# Changes to methods/integrations don't take effect until a new deployment is created
# This is why terraform apply is needed after changing API configuration
# ============================================================================

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_method.method
  ]
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
}

# ============================================================================
# STAGE (Environment)
# ============================================================================
# Deploys the API to a specific stage (e.g., "prod", "dev", "staging")
# Stage name becomes part of the URL: /{stage}/visitCount
# Each stage can have different settings (throttling, caching, logging)
# ============================================================================

resource "aws_api_gateway_stage" "dev_stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.visitor_counter_api.id
  stage_name    = var.environment_type # "prod" or "dev"
}

# ============================================================================
# LAMBDA PERMISSION
# ============================================================================
# Allows API Gateway to invoke the Lambda function
# Without this, API Gateway gets "AccessDenied" when trying to call Lambda
# source_arn restricts permission to only POST requests to this specific path
# ============================================================================

resource "aws_lambda_permission" "api_gw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.visitor_counter_api.execution_arn}/*/POST/${var.path_part}"
}

# ============================================================================
# POST METHOD RESPONSE (Contract/Schema)
# ============================================================================
# Declares what the POST method CAN return
# This is a schema declaration - actual values set in integration_response
# response_parameters: true = "this header is allowed to be returned"
# ============================================================================

resource "aws_api_gateway_method_response" "method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty" # No specific model validation
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true # CORS: Which domains can access
    "method.response.header.Access-Control-Allow-Methods" = true # CORS: Which HTTP methods allowed
    "method.response.header.Access-Control-Allow-Headers" = true # CORS: Which headers allowed
  }
}



# ============================================================================
# POST INTEGRATION RESPONSE (Actual Values)
# ============================================================================
# Sets the ACTUAL header values for POST responses
# Production: Only allows requests from https://lukamasa.com
# Dev: Allows requests from any origin (*)
# Note: Single quotes around values are required by API Gateway
# ============================================================================

resource "aws_api_gateway_integration_response" "integration_response_200" {
  depends_on  = [aws_api_gateway_method_response.method_response_200, aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = var.environment_type == "prod" ? "'https://lukamasa.com'" : "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  }

  response_templates = {
    "application/json" = "" # Empty = pass through Lambda response unchanged
  }

}

# ============================================================================
# OPTIONS METHOD - CORS Preflight
# ============================================================================
# Handles CORS preflight requests that browsers send automatically
# Browser flow:
#   1. Browser sees cross-origin POST request (lukamasa.com → amazonaws.com)
#   2. Browser sends OPTIONS request first to check if POST is allowed
#   3. Server responds with CORS headers
#   4. If allowed, browser proceeds with actual POST request
# 
# This happens automatically - frontend doesn't explicitly call OPTIONS
# ============================================================================

resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "OPTIONS"
  authorization = "NONE" # Preflight requests are never authenticated
}

# ============================================================================
# OPTIONS MOCK INTEGRATION
# ============================================================================
# Uses MOCK type - does NOT call Lambda!
# Why MOCK?
#   - Preflight requests don't need backend logic
#   - Faster response (no Lambda cold start)
#   - Free (no Lambda invocation cost)
#   - Reduces Lambda invocations by ~50% (every POST is preceded by OPTIONS)
# ============================================================================

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  type        = "MOCK" # Returns immediate response without backend call

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200 # Always return 200 OK for preflight
    })
  }
}

# ============================================================================
# OPTIONS METHOD RESPONSE (Schema)
# ============================================================================
# Declares that OPTIONS can return 200 with CORS headers
# ============================================================================

resource "aws_api_gateway_method_response" "options_method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

# ============================================================================
# OPTIONS INTEGRATION RESPONSE (Actual CORS Headers)
# ============================================================================
# Sets CORS headers for preflight response
# Note: OPTIONS allows '*' (any origin) even in prod because:
#   - It's just a permission check, not actual data access
#   - The POST method still restricts to lukamasa.com
#   - Browser needs to know IF it can proceed before revealing origin details
# ============================================================================

resource "aws_api_gateway_integration_response" "options_integration_response_200" {
  depends_on  = [aws_api_gateway_method_response.options_method_response_200, aws_api_gateway_integration.options_integration]
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"            # Allow preflight from any origin
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'" # Which methods are allowed
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  }

  response_templates = {
    "application/json" = ""
  }
}
