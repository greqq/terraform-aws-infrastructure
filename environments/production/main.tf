terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.11"
    }
  }

  required_version = ">= 1.2.0"

  backend "s3" {
  }
}

provider "aws" {
  region = var.aws_region
}

module "s3" {
  source                     = "../../modules/s3"
  aws_region                 = var.aws_region
  bucket_name                = var.bucket_name
  account_id                 = var.account_id
  cloudfront_distribution_id = var.cloudfront_distribution_id

}

module "s3_state" {
  source            = "../../modules/s3_state"
  aws_region        = var.aws_region
  state_bucket_name = var.state_bucket_name
}

module "cloudfront" {
  source                   = "../../modules/cloudfront"
  aliases                  = var.aliases
  acm_certificate_arn      = var.acm_certificate_arn
  cloudfront_comment       = var.cloudfront_comment
  price_class              = var.price_class
  origin_domain_name       = var.origin_domain_name
  origin_id                = var.origin_id
  origin_access_control_id = var.origin_access_control_id
  target_origin_id         = var.target_origin_id
  cache_policy_id          = var.cache_policy_id
  minimum_protocol_version = var.minimum_protocol_version
}

module "dynamodb" {
  source       = "../../modules/dynamodb"
  aws_region   = var.aws_region
  table_name   = var.table_name
  billing_mode = var.billing_mode
}

module "dynamodb_state" {
  source           = "../../modules/dynamodb_state"
  aws_region       = var.aws_region
  state_table_name = var.state_table_name
  billing_mode     = var.billing_mode
}

module "lambda" {
  source           = "../../modules/lambda"
  function_name    = var.function_name
  handler          = var.handler
  s3_bucket_lambda = var.s3_bucket_lambda
  s3_key_lambda    = var.s3_key_lambda
  role_name        = var.role_name
  role_path        = var.role_path
}

module "api_gateway" {
  source                    = "../../modules/api_gateway"
  lambda_invoke_arn         = module.lambda.visitor_counter_lambda_invoke_arn
  aws_region                = var.aws_region
  api_name                  = var.api_name
  path_part                 = var.path_part
  output_api_endpoint_value = var.output_api_endpoint_value

}
