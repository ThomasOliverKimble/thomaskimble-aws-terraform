# REST API
resource "aws_api_gateway_rest_api" "thomaskimble" {
  name = "thomaskimble"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


# Mock responses map data
locals {
  mock_responses_get = {
    about_page_content = "${path.module}/mock_responses/about_page_content.yaml"
    featured_projects  = "${path.module}/mock_responses/featured_projects.yaml"
  }
}

data "local_file" "mock_response_get_files" {
  for_each = local.mock_responses_get
  filename = each.value
}


# API Gateway mock get calls
resource "aws_api_gateway_resource" "mock_get_resources" {
  for_each    = local.mock_responses_get
  rest_api_id = aws_api_gateway_rest_api.thomaskimble.id
  parent_id   = aws_api_gateway_rest_api.thomaskimble.root_resource_id
  path_part   = each.key
}

resource "aws_api_gateway_method" "mock_get_methods" {
  for_each      = aws_api_gateway_resource.mock_get_resources
  rest_api_id   = aws_api_gateway_rest_api.thomaskimble.id
  resource_id   = each.value.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "mock_get_integrations" {
  for_each             = aws_api_gateway_method.mock_get_methods
  rest_api_id          = aws_api_gateway_rest_api.thomaskimble.id
  resource_id          = each.value.resource_id
  http_method          = each.value.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = <<EOF
      {
        "statusCode": 200
      }
    EOF
  }
}

resource "aws_api_gateway_integration_response" "mock_get_integration_responses" {
  for_each    = aws_api_gateway_method.mock_get_methods
  rest_api_id = aws_api_gateway_rest_api.thomaskimble.id
  resource_id = each.value.resource_id
  http_method = each.value.http_method
  status_code = "200"

  response_templates = {
    "application/json" = jsonencode(yamldecode(data.local_file.mock_response_get_files[each.key].content))
  }
}

resource "aws_api_gateway_method_response" "mock_get_method_responses" {
  for_each    = aws_api_gateway_method.mock_get_methods
  rest_api_id = aws_api_gateway_rest_api.thomaskimble.id
  resource_id = each.value.resource_id
  http_method = each.value.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}


# Deployment
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.thomaskimble.id
  triggers = {
    redeployment = sha1(jsonencode(
      [aws_api_gateway_rest_api.thomaskimble.body, aws_api_gateway_rest_api.thomaskimble.root_resource_id] +
      [for method in aws_api_gateway_method.mock_get_methods : method.id] +
      [for integration in aws_api_gateway_integration.mock_get_integrations : integration.id]
    ))
  }

  lifecycle {
    create_before_destroy = true
  }
}


# Stages
resource "aws_api_gateway_stage" "thomaskimble_prod" {
  rest_api_id   = aws_api_gateway_rest_api.thomaskimble.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  stage_name    = "prod"
}


# Domain name
resource "aws_api_gateway_domain_name" "thomaskimble_api_gateway_domain_name" {
  regional_certificate_arn = var.certificate_arn
  domain_name              = "api.thomaskimble.com"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "thomaskimble_api_gateway_mapping" {
  api_id      = aws_api_gateway_rest_api.thomaskimble.id
  stage_name  = aws_api_gateway_stage.thomaskimble_prod.stage_name
  domain_name = aws_api_gateway_domain_name.thomaskimble_api_gateway_domain_name.domain_name
}
