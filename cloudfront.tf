resource "aws_cloudfront_origin_access_control" "s3_origin" {
  name                              = var.origin_name
  description                       = var.origin_name
  origin_access_control_origin_type = var.origin_type
  signing_behavior                  = var.signing_behavior
  signing_protocol                  = var.signing_protocol
}



resource "aws_cloudfront_distribution" "s3_sub_distribution" {
  origin {
    domain_name              = aws_s3_bucket.sub_bucket.bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_origin.id
    origin_id                = var.origin_id
  }

  enabled             = var.true
  is_ipv6_enabled     = var.true
  default_root_object = var.HTML_file


  aliases = [var.subdomain]

  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.allowed_methods
    target_origin_id = var.origin_id

    forwarded_values {
      query_string = var.false

      cookies {
        forward = var.forward_none
      }
    }

    viewer_protocol_policy = var.redirect_policy
    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
  }

  restrictions {
    geo_restriction {
      restriction_type = var.restriction_type
      locations        = var.location_list
    }
  }



  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = var.ssl_support_method
  }

  depends_on = [aws_acm_certificate_validation.cert_valid, aws_s3_bucket.sub_bucket]
}

resource "aws_cloudfront_distribution" "s3_root_distribution" {
  origin {
    domain_name              = aws_s3_bucket.root_bucket.bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_origin.id
    origin_id                = var.origin_id
  }

  enabled             = var.true
  is_ipv6_enabled     = var.true
  default_root_object = var.HTML_file

  aliases = [var.rootdomain]

  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.allowed_methods
    target_origin_id = var.origin_id

    cache_policy_id = var.cache_policy_id

    viewer_protocol_policy = var.redirect_policy
    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
  }

  restrictions {
    geo_restriction {
      restriction_type = var.restriction_type
      locations        = var.location_list
    }
  }



  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = var.ssl_support_method
  }

  depends_on = [aws_acm_certificate_validation.cert_valid, aws_s3_bucket.root_bucket]
}