#Set terraform providers
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  region = var.region_name
}

#First register a new route53 domain in new account and then use terraform to create the rest of the hosted zones
#First create route53 resource with lifecycle = prevent_destroy
#create ACM certificate
#Then create S3 with static hosting enabled
#create a CF distribution
#Update Route53 DNS records to point to CF

/*1. Route 53 hosted zone (Done - kind of)
2. ACM certificate (Done)
3. S3 static hosting (Done - need to validate)
4. CloudFront distribution
5. Route 53 DNS records → point domain to CloudFront*/


#Manually register domain but show documnetation to register via:
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53domains_domain

resource "aws_acm_certificate" "cert" {
  domain_name               = "sabahatresume.com"
  subject_alternative_names = ["*.sabahatresume.com"]
  validation_method         = "DNS"
  key_algorithm             = "RSA_2048"

  lifecycle {
    create_before_destroy = true
  }
}

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

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  depends_on = [aws_s3_bucket.root_bucket]
}

resource "aws_s3_bucket_public_access_block" "s3_sub_access" {
  bucket = aws_s3_bucket.sub_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  depends_on = [aws_s3_bucket.sub_bucket]
}

resource "aws_s3_bucket_policy" "s3_root_policy" {
  bucket = aws_s3_bucket.root_bucket.id
  policy = jsonencode({
    "Id" : "Policy1746753478430",
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Stmt1746753474784",
        "Action" : [
          "s3:GetObject"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:s3:::sabahatresume.com/*",
        "Principal" : "*"
      }
    ]
  })

  depends_on = [aws_s3_bucket.root_bucket, aws_s3_bucket_public_access_block.s3_root_access]
}

resource "aws_s3_bucket_policy" "s3_sub_policy" {
  bucket = aws_s3_bucket.sub_bucket.id
  policy = jsonencode({
    "Id" : "Policy1746753589104",
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Stmt1746753586112",
        "Action" : [
          "s3:GetObject"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:s3:::www.sabahatresume.com/*",
        "Principal" : "*"
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


/*Bucket Policy Root

{
  "Id": "Policy1746753478430",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1746753474784",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::sabahatresume.com/*",
      "Principal": "*"
    }
  ]
}
*/

/*Bucket Policy Sub

{
  "Id": "Policy1746753589104",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1746753586112",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::www.sabahatresume.com/*",
      "Principal": "*"
    }
  ]
}

*/

