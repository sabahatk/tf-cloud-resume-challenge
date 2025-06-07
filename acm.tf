resource "aws_acm_certificate" "cert" {
  provider                  = aws
  domain_name               = var.rootdomain
  subject_alternative_names = [var.subdomain, var.api_domain]
  validation_method         = var.valid_DNS
  key_algorithm             = var.key_alg

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_s3_bucket.root_bucket, aws_s3_bucket.sub_bucket]
}

resource "aws_acm_certificate_validation" "cert_valid" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_record : record.fqdn]
}

resource "aws_acm_certificate" "api_cert" {
  provider          = aws
  domain_name       = var.api_domain
  validation_method = var.valid_DNS
  key_algorithm     = var.key_alg
}

resource "aws_acm_certificate_validation" "api_cert_valid" {
  provider                = aws
  certificate_arn         = aws_acm_certificate.api_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_record : record.fqdn]
}
