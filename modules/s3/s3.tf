provider "aws" {
  region  = var.aws_region
}

resource "aws_s3_bucket" "webflow_projects_assets" {
  bucket = var.bucket_name
  force_destroy = false 

}

resource "aws_s3_bucket_policy" "webflow_s3_bucket_policy" {
  bucket = aws_s3_bucket.webflow_projects_assets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::${var.bucket_name}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::${var.account_id}:distribution/${var.cloudfront_distribution_id}"
          }
        }
      },
    ]
  })
}