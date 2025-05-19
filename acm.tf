resource "aws_acm_certificate" "cert" {
  domain_name               = "sabahatresume.com"
  subject_alternative_names = ["*.sabahatresume.com"]
  validation_method         = "DNS"
  key_algorithm             = "RSA_2048"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert_valid" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_record : record.fqdn]
}
