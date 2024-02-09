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


module "certificate" {
  source      = "../../modules/certificate"
  domain_name = var.domain_name
}

module "s3" {
  source                     = "../../modules/s3"
  bucket_name                = var.bucket_name
  cloudfront_distribution_id = module.cloudfront.distribution_id
}

module "cloudfront" {
  source                   = "../../modules/cloudfront"
  aliases                  = var.aliases
  acm_certificate_arn      = module.certificate.certificate_arn
  cloudfront_comment       = var.cloudfront_comment
  bucket_name              = var.bucket_name
  aws_region               = var.aws_region
  price_class              = var.price_class
  minimum_protocol_version = var.minimum_protocol_version
  environment_type         = var.environment_type
}

module "dynamodb" {
  source                     = "../../modules/dynamodb"
  visitor_counter_table_name = var.visitor_counter_table_name
  billing_mode               = var.billing_mode
}

module "dynamodb_unique_visits" {
  source                    = "../../modules/dynamodb_unique_visits"
  unique_visitor_table_name = var.unique_visitor_table_name
  billing_mode              = var.billing_mode
}

module "lambda" {
  source                     = "../../modules/lambda"
  function_name              = var.function_name
  handler                    = var.handler
  s3_bucket_lambda           = var.s3_bucket_lambda
  s3_key_lambda              = var.s3_key_lambda
  role_name                  = var.role_name
  role_path                  = var.role_path
  visitor_counter_table_name = var.visitor_counter_table_name
  unique_visitor_table_name  = var.unique_visitor_table_name
  environment_type           = var.environment_type
}

module "api_gateway" {
  source            = "../../modules/api_gateway"
  lambda_invoke_arn = module.lambda.visitor_counter_lambda_invoke_arn
  api_name          = var.api_name
  path_part         = var.path_part
  function_name     = var.function_name
  environment_type  = var.environment_type
}