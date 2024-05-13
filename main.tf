resource "aws_route53_zone" "thomaskimble" {
  name = "thomaskimble.com"
}


resource "aws_route53_zone" "thomaskimble_www" {
  name = "www.thomaskimble.com"
}

resource "aws_route53_zone" "thomaskimble_dev" {
  name = "dev.thomaskimble.com"
}

resource "aws_route53_zone" "thomaskimble_legacy" {
  name = "legacy.thomaskimble.com"
}

resource "aws_route53_record" "thomaskimble_dev_cname" {
  zone_id = aws_route53_zone.thomaskimble.zone_id
  name    = "dev.thomaskimble.com"
  type    = "CNAME"
  ttl     = "600"
  records = aws_route53_zone.thomaskimble_dev.name_servers
}

resource "aws_route53_record" "thomaskimble_legacy_cname" {
  zone_id = aws_route53_zone.thomaskimble.zone_id
  name    = "legacy.thomaskimble.com"
  type    = "CNAME"
  ttl     = "600"
  records = aws_route53_zone.thomaskimble_legacy.name_servers
}
