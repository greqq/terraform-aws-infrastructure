# ============================================================================
# S3 MODULE - Static Website Hosting
# ============================================================================
# This module creates an S3 bucket for hosting the Next.js static website
#
# ARCHITECTURE:
#   User → CloudFront (CDN) → S3 Bucket (Private)

# ============================================================================

# Get current AWS account ID for use in bucket policy
data "aws_caller_identity" "current" {}

# ============================================================================
# S3 BUCKET - Website Storage
# ============================================================================
# Creates private S3 bucket for static website files

# ============================================================================

resource "aws_s3_bucket" "webflow_projects_assets" {
  bucket        = var.bucket_name
  force_destroy = false           # Safety: prevents accidental deletion of website
}


# ============================================================================
# PLACEHOLDER INDEX.HTML
# ============================================================================
# Creates initial placeholder file so bucket isn't empty
# This gets overwritten by CI/CD pipeline during first deployment
# Shows "Under Construction" until real site is deployed
# ============================================================================

resource "aws_s3_object" "index_html" {
  depends_on   = [aws_s3_bucket.webflow_projects_assets]
  bucket       = var.bucket_name
  key          = "index.html"
  content_type = "text/html"
  content      = <<-EOF
    <html>
    <head><title>Website Under Construction</title></head>
    <body>
      <h1>Under Construction</h1>
    </body>
    </html>
  EOF
}

# ============================================================================
# BUCKET POLICY - CloudFront Access Only
# ============================================================================
# Grants CloudFront exclusive access to S3 bucket
# ============================================================================

resource "aws_s3_bucket_policy" "webflow_s3_bucket_policy" {
  bucket = aws_s3_bucket.webflow_projects_assets.id

  policy = templatefile("../../modules/s3/s3_bucket_policy.tpl", {
    bucket_name                = var.bucket_name
    account_id                 = data.aws_caller_identity.current.account_id
    cloudfront_distribution_id = var.cloudfront_distribution_id
  })
}