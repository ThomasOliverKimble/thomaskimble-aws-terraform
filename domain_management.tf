resource "aws_acm_certificate" "thomaskimble_certificate" {
    domain_name               = "thomaskimble.net"
    subject_alternative_names = ["*.thomaskimble.net"]
    validation_method         = "DNS"

    lifecycle {
        create_before_destroy = true
    }
}

data "aws_route53_zone" "thomaskimble" {
  name         = "thomaskimble.com"
  private_zone = false
}


# variable "domains" {
#     type = list
#     default = [
#         "thomaskimble.com",
#         "*.thomaskimble.com",
#     ]
# }

# resource "aws_acm_certificate" "thomaskimble_certificates" {
#   count             = length(var.domains)
#   domain_name       = element(var.domains, count.index)
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_acm_certificate_validation" "thomaskimble_certificate_validations" {
#   for_each = { for cert in aws_acm_certificate.thomaskimble_certificates : cert.domain_name => cert }

#   certificate_arn      = each.value.arn
#   validation_record_fqdns = [
#     for dvo in each.value.domain_validation_options : aws_route53_record.thomaskimble_records[dvo.domain_name].fqdn
#   ]
# }

# data "aws_route53_zone" "thomaskimble_zone" {
#   name         = "thomaskimble.com"
#   private_zone = false
# }

# resource "aws_route53_record" "thomaskimble_records" {
#   for_each = tomap({
#     for dvo in flatten([
#       for cert in aws_acm_certificate.thomaskimble_certificate : 
#         cert.domain_validation_options
#     ]) : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   })

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = data.aws_route53_zone.thomaskimble_zone.zone_id
# }

