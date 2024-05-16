variable "hosted_zone" {
  description = "Hosted zone for the app."
  type        = string
}

variable "certificate_arn" {
  description = "the acm certificate validation for the domain."
  type        = string
}
