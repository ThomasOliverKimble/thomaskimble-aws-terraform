output "dynamodb_projects_table_arn" {
  value = aws_dynamodb_table.projects.arn
}

output "dynamodb_projects_table_name" {
  value = aws_dynamodb_table.projects.name
}
