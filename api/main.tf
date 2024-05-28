# REST API
resource "aws_api_gateway_rest_api" "thomaskimble" {
  name = "thomaskimble"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


# Mock Calls
locals {
  mock_responses_get = {
    about_page_content = "${path.module}/mock_responses/GetAboutPageContent.yaml"
    featured_projects  = "${path.module}/mock_responses/GetFeaturedProjects.yaml"
    projects_mock      = "${path.module}/mock_responses/GetProjectsMock.yaml"
  }
}

data "local_file" "mock_response_get_files" {
  for_each = local.mock_responses_get
  filename = each.value
}

resource "aws_api_gateway_resource" "mock_get_resources" {
  for_each    = local.mock_responses_get
  rest_api_id = aws_api_gateway_rest_api.thomaskimble.id
  parent_id   = aws_api_gateway_rest_api.thomaskimble.root_resource_id
  path_part   = replace(basename(each.value), ".yaml", "")
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

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
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

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}


# Get Projects Resources
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name = "lambda_dynamodb_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.projects.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

resource "aws_lambda_function" "get_projects" {
  function_name = "GetProjectsFunction"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.10"
  role          = aws_iam_role.lambda_execution_role.arn

  filename = "${path.module}/lambda/get_projects.py"

  source_code_hash = filebase64sha256("${path.module}/lambda/get_projects.py")

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.dynamodb_projects_table_name
    }
  }
}

resource "aws_lambda_permission" "api_gateway_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_projects.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_api_gateway_resource" "get_projects_resource" {
  rest_api_id = aws_api_gateway_rest_api.thomaskimble.id
  parent_id   = aws_api_gateway_rest_api.thomaskimble.root_resource_id
  path_part   = "GetProjects"
}

resource "aws_api_gateway_method" "get_projects_method" {
  rest_api_id   = aws_api_gateway_rest_api.thomaskimble.id
  resource_id   = aws_api_gateway_resource.get_projects_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_projects_integration" {
  rest_api_id             = aws_api_gateway_rest_api.thomaskimble.id
  resource_id             = aws_api_gateway_resource.get_projects_resource.id
  http_method             = aws_api_gateway_method.get_projects_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_projects.invoke_arn

  depends_on = [
    aws_lambda_permission.api_gateway_lambda_permission
  ]
}


# CORS OPTIONS Methods
resource "aws_api_gateway_method" "cors_options_methods" {
  for_each      = aws_api_gateway_resource.mock_get_resources
  rest_api_id   = aws_api_gateway_rest_api.thomaskimble.id
  resource_id   = each.value.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors_options_integration" {
  for_each    = aws_api_gateway_method.cors_options_methods
  rest_api_id = aws_api_gateway_rest_api.thomaskimble.id
  resource_id = each.value.resource_id
  http_method = each.value.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
      {
        "statusCode": 200
      }
    EOF
  }
}

resource "aws_api_gateway_method_response" "cors_options_method_responses" {
  for_each    = aws_api_gateway_method.cors_options_methods
  rest_api_id = aws_api_gateway_rest_api.thomaskimble.id
  resource_id = each.value.resource_id
  http_method = each.value.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }

  response_models = {
    "application/json" = "Empty"
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
  domain_name              = "api.${var.hosted_zone}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "thomaskimble_api_gateway_mapping" {
  api_id      = aws_api_gateway_rest_api.thomaskimble.id
  stage_name  = aws_api_gateway_stage.thomaskimble_prod.stage_name
  domain_name = aws_api_gateway_domain_name.thomaskimble_api_gateway_domain_name.domain_name
}
