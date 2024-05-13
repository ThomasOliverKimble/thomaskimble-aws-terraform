resource "aws_route53_zone" "thomaskimble" {
  name = "thomaskimble.com"
}

variable "domains" {
    type = list
    default = [
        "example.com",
        "*.example.com",
    ]
}

resource "aws_acm_certificate" "thomaskimble_certificate" {
  count             = "${length(var.domains)}"
  domain_name       = "${element(var.domains, count.index)}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
