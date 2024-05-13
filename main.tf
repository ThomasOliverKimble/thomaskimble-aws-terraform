variable "domains" {
    type = list
    default = [
        "thomaskimble.com",
        "*.thomaskimble.com",
    ]
}

resource "aws_acm_certificate" "thomaskimble_certificate" {
  count             = length(var.domains)
  domain_name       = element(var.domains, count.index)
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "thomaskimble_certificate_validation" {
  for_each             = { for cert in aws_acm_certificate.thomaskimble_certificate : cert.domain_name => cert.arn }
  certificate_arn      = each.value

  validation_record_fqdns = flatten([
    for dvo in aws_acm_certificate.thomaskimble_certificate[each.key].domain_validation_options : 
      lookup(aws_route53_record.thomaskimble_records, dvo.domain_name, null) != null ? [aws_route53_record.thomaskimble_records[dvo.domain_name].fqdn] : []
  ])
}

data "aws_route53_zone" "thomaskimble" {
  name         = "thomaskimble.com"
  private_zone = false
}

resource "aws_route53_record" "thomaskimble_records" {
  for_each = tomap({
    for dvo in flatten([
      for cert in aws_acm_certificate.thomaskimble_certificate : 
        cert.domain_validation_options
    ]) : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  })

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.thomaskimble.zone_id
}

