# Providers
terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = "~> 1.6"
}

provider "aws" {
  region = "eu-west-1"
}


# Locals
locals {
  hosted_zone = "thomaskimble.com"
}


# Modules
module "api" {
  source          = "./api"
  certificate_arn = module.domain_management.thomaskimble_certificate_validation_arn
  hosted_zone     = local.hosted_zone
}

module "cdn" {
  source                      = "./cdn"
  bucket_regional_domain_name = module.storage.thomaskimble_bucket_regional_domain_name
  certificate_arn             = module.domain_management.thomaskimble_certificate_validation_arn
  hosted_zone                 = local.hosted_zone
}

module "domain_management" {
  source                              = "./domain_management"
  regional_domain_name                = module.api.thomaskimble_api_domain_name
  regional_zone_id                    = module.api.thomaskimble_api_zone_id
  bucket_regional_domain_name         = module.storage.thomaskimble_bucket_regional_domain_name
  hosted_zone                         = local.hosted_zone
  cloudfront_distribution_domain_name = module.cdn.cloudfront_distribution_domain_name
}

module "frontend" {
  source      = "./frontend"
  hosted_zone = local.hosted_zone
}

module "storage" {
  source      = "./storage"
  hosted_zone = local.hosted_zone
}
