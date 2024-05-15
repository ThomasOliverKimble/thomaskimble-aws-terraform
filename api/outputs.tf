output "thomaskimble_api_domain_name" {
  value = aws_api_gateway_domain_name.thomaskimble_api_gateway_domain_name.regional_domain_name
}

output "thomaskimble_api_zone_id" {
  value = aws_api_gateway_domain_name.thomaskimble_api_gateway_domain_name.regional_zone_id
}
