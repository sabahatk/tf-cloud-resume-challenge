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
3. S3 static hosting (Done)
4. CloudFront distribution (Done)
5. Route 53 DNS records → point domain to CloudFront

TO DO:
Create prevent_destroy for certificates, validations, route53 records and CF distributions
Create Cloudfront distribution for S3 root domain
Update CloudFront policy for both root and subdomains
Create records for Route53 for subdomain and domain CF distributions
Work on creating a script*/


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

data "aws_route53_zone" "domain_zone" {
  name         = "sabahatresume.com" # Replace with your domain name
  private_zone = false
}

resource "aws_route53_record" "cert_record" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.domain_zone.id
}

resource "aws_acm_certificate_validation" "cert_valid" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_record : record.fqdn]
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

resource "aws_cloudfront_origin_access_control" "s3_origin" {
  name                              = "S3 Origin"
  description                       = "S3 Origin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}



resource "aws_cloudfront_distribution" "s3_sub_distribution" {
  origin {
    domain_name              = aws_s3_bucket.sub_bucket.bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_origin.id
    origin_id                = "myS3Origin"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"


  aliases = [var.subdomain]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "myS3Origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }



  viewer_certificate {
    #cloudfront_default_certificate = true
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
  }

  depends_on = [aws_acm_certificate_validation.cert_valid, aws_s3_bucket.sub_bucket]
}

resource "aws_cloudfront_distribution" "s3_root_distribution" {
  origin {
    domain_name              = aws_s3_bucket.root_bucket.bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_origin.id
    origin_id                = "myS3Origin"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = [var.rootdomain]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "myS3Origin"

    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" #Disable Caching

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }



  viewer_certificate {
    #cloudfront_default_certificate = true
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
  }

  depends_on = [aws_acm_certificate_validation.cert_valid, aws_s3_bucket.root_bucket]
}

resource "aws_route53_record" "r53_subdomain" {
  zone_id = data.aws_route53_zone.domain_zone.id
  name    = var.subdomain
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.s3_sub_distribution.domain_name
    zone_id                = var.cf_hosted_zone
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "r53_rootdomain" {
  zone_id = data.aws_route53_zone.domain_zone.id
  name    = var.rootdomain
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.s3_root_distribution.domain_name
    zone_id                = var.cf_hosted_zone
    evaluate_target_health = true
  }
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

#To do: Look at ACM certificate. Need to fix it

#Getting this error: │ Error: creating CloudFront Distribution: operation error CloudFront: CreateDistributionWithTags, https response error StatusCode: 400, RequestID: 79f097d4-85e1-4432-bf72-8bece294dc3c, InvalidArgument: The parameter ViewerCertificate Unsupported value for the SSLSupportMethod field: null.
# Getting this error when not using ACM: │ Error: creating CloudFront Distribution: operation error CloudFront: CreateDistributionWithTags, https response error StatusCode: 400, RequestID: 4f2e2859-085b-4c81-9cdc-d0e9d13ccf1a, InvalidViewerCertificate: To add an alternate domain name (CNAME) to a CloudFront distribution, you must attach a trusted certificate that validates your authorization to use the domain name. For more details, see: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/CNAMEs.html#alternate-domain-names-requirements
