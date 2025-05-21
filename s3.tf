resource "aws_s3_bucket" "root_bucket" {
  bucket        = var.rootdomain
  force_destroy = true
}

resource "aws_s3_bucket" "sub_bucket" {
  bucket        = var.subdomain
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "s3_root_access" {
  bucket = aws_s3_bucket.root_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket.root_bucket]
}

resource "aws_s3_bucket_public_access_block" "s3_sub_access" {
  bucket = aws_s3_bucket.sub_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket.sub_bucket]
}

resource "aws_s3_bucket_policy" "s3_root_policy" {
  bucket = aws_s3_bucket.root_bucket.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "s3:GetObject",
        "Effect" : "Allow",
        "Resource" : "${aws_s3_bucket.root_bucket.arn}/*",
        "Principal" : {
          Service = "cloudfront.amazonaws.com"
        }
        Condition : {
          StringEquals : {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_root_distribution.arn
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket.root_bucket, aws_s3_bucket_public_access_block.s3_root_access]
}

resource "aws_s3_bucket_policy" "s3_sub_policy" {
  bucket = aws_s3_bucket.sub_bucket.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "s3:GetObject",
        "Effect" : "Allow",
        "Resource" : "${aws_s3_bucket.sub_bucket.arn}/*",
        "Principal" : {
          Service = "cloudfront.amazonaws.com"
        }
        Condition : {
          StringEquals : {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_sub_distribution.arn
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket.sub_bucket, aws_s3_bucket_public_access_block.s3_sub_access]
}

resource "aws_s3_object" "root_files" {
  for_each = toset(var.s3_objects)
  bucket   = aws_s3_bucket.root_bucket.id
  key      = "${path.module}/${each.key}"
  source   = "${path.module}/${each.key}"
  content_type = lookup({
    "index.html" = "text/html",
    "styles.css" = "text/css",
    "index.js"   = "application/javascript",
    "error.html" = "text/html"
  }, each.value, "application/octet-stream")
}

resource "aws_s3_object" "sub_files" {
  for_each = toset(var.s3_objects)
  bucket   = aws_s3_bucket.sub_bucket.id
  key      = "${path.module}/${each.key}"
  source   = "${path.module}/${each.key}"
  content_type = lookup({
    "index.html" = "text/html",
    "styles.css" = "text/css",
    "index.js"   = "application/javascript",
    "error.html" = "text/html"
  }, each.value, "application/octet-stream")
}

resource "aws_s3_bucket_website_configuration" "root_s3_config" {
  bucket = aws_s3_bucket.root_bucket.id

  redirect_all_requests_to {
    host_name = var.subdomain
    protocol  = "https"
  }

  depends_on = [aws_s3_bucket.root_bucket, aws_s3_bucket.sub_bucket, aws_s3_object.root_files, aws_s3_object.sub_files]
}

resource "aws_s3_bucket_website_configuration" "sub_s3_config" {
  bucket = aws_s3_bucket.sub_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [aws_s3_bucket.root_bucket, aws_s3_bucket.sub_bucket, aws_s3_object.root_files, aws_s3_object.sub_files]
}
