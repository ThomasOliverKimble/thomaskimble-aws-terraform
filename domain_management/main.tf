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
  zone_id         = aws_route53_zone.thomaskimble_zone.zone_id
}

resource "aws_route53_record" "thomaskimble_github_pages_record" {
  zone_id = aws_route53_zone.thomaskimble_zone.zone_id
  name    = "legacy"
  type    = "CNAME"
  ttl     = 300
  records = ["thomasoliverkimble.github.io."]
}

resource "aws_route53_record" "thomaskimble_outlook_autodiscover_record" {
  zone_id = aws_route53_zone.thomaskimble_zone.zone_id
  name    = "autodiscover"
  type    = "CNAME"
  ttl     = 300
  records = ["autodiscover.outlook.com"]
}

resource "aws_route53_record" "thomaskimble_email_secureserver_record" {
  zone_id = aws_route53_zone.thomaskimble_zone.zone_id
  name    = "email"
  type    = "CNAME"
  ttl     = 300
  records = ["email.secureserver.net"]
}

resource "aws_route53_record" "thomaskimble_outlook_mx_record" {
  zone_id = aws_route53_zone.thomaskimble_zone.zone_id
  name    = ""
  type    = "MX"
  ttl     = 300
  records = ["0 thomaskimble-com.mail.protection.outlook.com"]
}

resource "aws_route53_record" "thomaskimble_txt_records" {
  zone_id = aws_route53_zone.thomaskimble_zone.zone_id
  name    = ""
  type    = "TXT"
  ttl     = 300
  records = ["NETORGFT11093738.onmicrosoft.com", "v=spf1 include:secureserver.net -all"]
}

resource "aws_route53_record" "example" {
  zone_id = aws_route53_zone.thomaskimble_zone.zone_id
  name    = "api"
  type    = "A"

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.thomaskimble_api_gateway_domain_name.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.thomaskimble_api_gateway_domain_name.regional_zone_id
  }
}
