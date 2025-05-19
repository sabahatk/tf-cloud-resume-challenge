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