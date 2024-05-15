resource "aws_api_gateway_rest_api" "thomaskimble" {
  name = "thomaskimble"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "get_projects" {
  rest_api_id = aws_api_gateway_rest_api.thomaskimble.id
  parent_id   = aws_api_gateway_rest_api.thomaskimble.root_resource_id
  path_part   = "GetProjects"
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.thomaskimble.id
  resource_id   = aws_api_gateway_resource.get_projects.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_integration" {
  rest_api_id = aws_api_gateway_rest_api.thomaskimble.id
  resource_id = aws_api_gateway_resource.get_projects.id
  http_method = aws_api_gateway_method.post_method.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
  "statusCode": 200
}
EOF
  }

  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_integration_response" "post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.thomaskimble.id
  resource_id = aws_api_gateway_resource.get_projects.id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = "200"

  response_templates = {
    "application/json" = <<EOF
      {
          "title": "About Me",
          "date": "2021-02-27T17:01:34+01:00",
          "layout": "page",
          "bodyClass": "page-about",
          "sections": [
              {
                  "type": "text",
                  "content": "My name is **Thomas Oliver Kimble**, an engineer with a rich blend of skills and interests, encompassing data science, robotics, cloud engineering, and a strong passion for both music and design."
              },
              {
                  "type": "image",
                  "src": "/images/about/Me.jpg",
                  "class": "web-image-md"
              },
              {
                  "type": "header",
                  "content": "Personal Life"
              },
              {
                  "type": "text",
                  "content": "Hailing originally from England, my early years were marked by a move to Switzerland at three and a subsequent relocation to France. Despite these geographical shifts, my educational journey was primarily Swiss-based. Engineering was a natural choice for me, harmonizing my fascination with maths and science and my keen eye for design and aesthetics. This path has enabled me to merge analytical precision with creative expression, a duality that is evident in my music pursuits. Having been surrounded by music, especially the guitar, from the age of seven, I've explored various musical avenues, playing in bands and experimenting with instruments like the drums and piano."
              }
          ]
      }
      EOF
  }
}

resource "aws_api_gateway_method_response" "post_method_response" {
  rest_api_id = aws_api_gateway_rest_api.thomaskimble.id
  resource_id = aws_api_gateway_resource.get_projects.id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [aws_api_gateway_method.post_method]
  rest_api_id = aws_api_gateway_rest_api.thomaskimble.id
  stage_name  = "prod"
}
