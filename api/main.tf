resource "aws_api_gateway_rest_api" "thomaskimble" {
  name = "thomaskimble"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "about_page_content" {
  rest_api_id = aws_api_gateway_rest_api.thomaskimble.id
  parent_id   = aws_api_gateway_rest_api.thomaskimble.root_resource_id
  path_part   = "AboutPageContent"
}

resource "aws_api_gateway_method" "about_page_content_method" {
  rest_api_id   = aws_api_gateway_rest_api.thomaskimble.id
  resource_id   = aws_api_gateway_resource.about_page_content.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "about_page_content_integration" {
  rest_api_id          = aws_api_gateway_rest_api.thomaskimble.id
  resource_id          = aws_api_gateway_resource.about_page_content.id
  http_method          = aws_api_gateway_method.about_page_content_method.http_method
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

resource "aws_api_gateway_integration_response" "about_page_content_integration_response" {
  depends_on = [aws_api_gateway_integration.about_page_content_integration]

  rest_api_id = aws_api_gateway_rest_api.thomaskimble.id
  resource_id = aws_api_gateway_resource.about_page_content.id
  http_method = aws_api_gateway_method.about_page_content_method.http_method
  status_code = "200"

  response_templates = {
    "application/json" = <<EOF
      {
          "title": "About Me",
          "date": "2024-05-14T15:23:56Z",
          "bodyClass": "page-about",
          "sections": [
              {
                  "type": "text",
                  "content": "My name is **Thomas Oliver Kimble**, an engineer with a rich blend of skills and interests, encompassing data science, robotics, cloud engineering, and a strong passion for both music and design."
              },
              {
                  "type": "image",
                  "src": "/images/about/me.jpg"
              },
              {
                  "type": "header",
                  "content": "Personal Life"
              },
              {
                  "type": "text",
                  "content": "Originally from England, I moved to Switzerland when I was three and later to France. My education was mainly in Switzerland, where I pursued engineering—a field that aligned perfectly with my passion for math, science, and design. This combination of interests led me to explore both the analytical and creative sides of my personality, particularly through music. From the age of seven, I was immersed in music, playing in bands and learning instruments like the guitar, drums, and piano."
              }
          ]
      }
    EOF
  }
}

resource "aws_api_gateway_method_response" "about_page_content_method_response" {
  rest_api_id = aws_api_gateway_rest_api.thomaskimble.id
  resource_id = aws_api_gateway_resource.about_page_content.id
  http_method = aws_api_gateway_method.about_page_content_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [aws_api_gateway_integration_response.about_page_content_integration_response]

  rest_api_id = aws_api_gateway_rest_api.thomaskimble.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.thomaskimble.body,
      aws_api_gateway_rest_api.thomaskimble.root_resource_id,
      aws_api_gateway_method.about_page_content_method.id,
      aws_api_gateway_integration.about_page_content_integration.id,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "thomaskimble_prod" {
  rest_api_id   = aws_api_gateway_rest_api.thomaskimble.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  stage_name    = "prod"
}

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
