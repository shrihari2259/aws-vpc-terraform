### S3 Bucket
resource "aws_s3_bucket" "static_site" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  tags = {
    Name = "${var.environment}-static-site"
  }
}

### Enable Static Website Hosting
resource "aws_s3_bucket_website_configuration" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

### Disable Block Public Access (required for static hosting)
resource "aws_s3_bucket_public_access_block" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

### Bucket Policy — allow public read on all objects
resource "aws_s3_bucket_policy" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  depends_on = [aws_s3_bucket_public_access_block.static_site]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_site.arn}/*"
      }
    ]
  })
}

### Enable Versioning
resource "aws_s3_bucket_versioning" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  versioning_configuration {
    status = "Enabled"
  }
}

### Upload a sample index.html
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.static_site.id
  key          = "index.html"
  content_type = "text/html"

  content = <<-HTML
    <!DOCTYPE html>
    <html>
      <head><title>Terraform Static Site</title></head>
      <body>
        <h1>Hello from S3 Static Site!</h1>
        <p>Provisioned with Terraform by Shrihari Shinde.</p>
      </body>
    </html>
  HTML
}
