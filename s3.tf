resource "aws_s3_bucket" "root_bucket" {
  bucket        = var.rootdomain
  force_destroy = var.true
}

resource "aws_s3_bucket" "sub_bucket" {
  bucket        = var.subdomain
  force_destroy = var.true
}

resource "aws_s3_bucket_public_access_block" "s3_root_access" {
  bucket = aws_s3_bucket.root_bucket.id

  block_public_acls       = var.true
  block_public_policy     = var.true
  ignore_public_acls      = var.true
  restrict_public_buckets = var.true

  depends_on = [aws_s3_bucket.root_bucket]
}

resource "aws_s3_bucket_public_access_block" "s3_sub_access" {
  bucket = aws_s3_bucket.sub_bucket.id

  block_public_acls       = var.true
  block_public_policy     = var.true
  ignore_public_acls      = var.true
  restrict_public_buckets = var.true

  depends_on = [aws_s3_bucket.sub_bucket]
}

resource "aws_s3_bucket_policy" "s3_root_policy" {
  bucket = aws_s3_bucket.root_bucket.id
  policy = local.s3_root_policy

  depends_on = [aws_s3_bucket.root_bucket, aws_s3_bucket_public_access_block.s3_root_access]
}

resource "aws_s3_bucket_policy" "s3_sub_policy" {
  bucket = aws_s3_bucket.sub_bucket.id
  policy = local.s3_sub_policy

  depends_on = [aws_s3_bucket.sub_bucket, aws_s3_bucket_public_access_block.s3_sub_access]
}

resource "aws_s3_object" "root_files" {
  for_each = toset(var.s3_objects)
  bucket   = aws_s3_bucket.root_bucket.id
  key      = "${path.module}/website/${each.key}"
  source   = "${path.module}/website/${each.key}"
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
  key      = "${path.module}/website/${each.key}"
  source   = "${path.module}/website/${each.key}"
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
    protocol  = var.s3_redirect_protocol
  }

  depends_on = [aws_s3_bucket.root_bucket, aws_s3_bucket.sub_bucket, aws_s3_object.root_files, aws_s3_object.sub_files]
}

resource "aws_s3_bucket_website_configuration" "sub_s3_config" {
  bucket = aws_s3_bucket.sub_bucket.id

  index_document {
    suffix = var.HTML_file
  }

  error_document {
    key = var.error_HTML_file
  }

  depends_on = [aws_s3_bucket.root_bucket, aws_s3_bucket.sub_bucket, aws_s3_object.root_files, aws_s3_object.sub_files]
}
