variable "hosted_zone" {
  description = "Hosted zone for the app."
  type        = string
}

variable "regional_domain_name" {
  description = "API regional domain name."
  type        = string
}

variable "regional_zone_id" {
  description = "API regional zone id."
  type        = string
}

variable "bucket_regional_domain_name" {
  description = "S3 regional domain name."
  type        = string
}

variable "cloudfront_distribution_domain_name" {
  description = "CloudFront distribution domain name."
  type        = string
}

variable "cloudfront_zone_id" {
  description = "Cloudfront zone id."
  type        = string
  default     = "Z2FDTNDATAQYW2"
}
