resource "aws_acm_certificate" "thomaskimble_certificate" {
    domain_name               = "thomaskimble.com"
    subject_alternative_names = ["*.thomaskimble.com"]
    validation_method         = "DNS"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_acm_certificate_validation" "thomaskimble_certificate_validation" {
  certificate_arn         = aws_acm_certificate.thomaskimble_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.thomaskimble_records : record.fqdn]
}

resource "aws_route53_zone" "thomaskimble_zone" {
    name = "thomaskimble.com"
}

resource "aws_route53_record" "thomaskimble_records" {
  for_each = {
    for dvo in aws_acm_certificate.thomaskimble_certificate.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.thomaskimble_zone.zone_id
}
