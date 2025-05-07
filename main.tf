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

resource "aws_s3_object" "root_files" {
  for_each = var.s3_objects
  bucket   = aws_s3_bucket.root_bucket.id
  key      = each.key
  source   = each.key
}

resource "aws_s3_object" "sub_files" {
  for_each = var.s3_objects
  bucket   = aws_s3_bucket.sub_bucket.id
  key      = each.key
  source   = each.key
}

resource "aws_s3_bucket_website_configuration" "root_s3_config" {
  bucket = aws_s3_bucket.root_bucket.id

  redirect_all_requests_to {
    host_name = var.subdomain
    protocol  = "https"
  }
}


