resource "aws_api_gateway_rest_api" "thomaskimble_api" {
  name = "thomaskimble-api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
