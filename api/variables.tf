variable "hosted_zone" {
  description = "Hosted zone for the app."
  type        = string
}

variable "certificate_arn" {
  description = "The acm certificate validation for the domain."
  type        = string
}

variable "dynamodb_projects_table_name" {
  description = "The DynamoDB projects table name."
  type        = string
}
