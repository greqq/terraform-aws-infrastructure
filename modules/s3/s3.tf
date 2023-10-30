provider "aws" {
  region  = var.aws_region
}

resource "aws_s3_bucket" "webflow_projects_assets" {
  bucket = var.bucket_name
  force_destroy = false 

}