variable "hosted_zone" {
  description = "Hosted zone for the app."
  type        = string
}

variable "bucket_regional_domain_name" {
  description = "The S3 bucket where content to be delivered is stored."
  type        = string
}
