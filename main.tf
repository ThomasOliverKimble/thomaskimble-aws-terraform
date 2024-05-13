resource "aws_route53_zone" "thomaskimble" {
  name = "thomaskimble.com"
}

resource "aws_acm_certificate" "thomaskimble_certificate" {
  domain_name       = "thomaskimble.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
