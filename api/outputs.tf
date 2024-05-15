output "api_endpoint" {
  value = "${aws_api_gateway_stage.prod.invoke_url}/${aws_api_gateway_resource.about_page_content.path_part}"
}

output "api_gateway_url" {
  value = aws_api_gateway_deployment.api_deployment.invoke_url
}

output "api_deployment_arn" {
  value = aws_api_gateway_deployment.api_deployment.execution_arn
}
