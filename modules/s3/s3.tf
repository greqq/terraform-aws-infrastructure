data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "webflow_projects_assets" {
  bucket        = var.bucket_name
  force_destroy = true
}


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

resource "aws_s3_bucket_policy" "webflow_s3_bucket_policy" {
  bucket = aws_s3_bucket.webflow_projects_assets.id

  policy = templatefile("../../modules/s3/s3_bucket_policy.tpl", {
    bucket_name                = var.bucket_name
    account_id                 = data.aws_caller_identity.current.account_id
    cloudfront_distribution_id = var.cloudfront_distribution_id
  })
}