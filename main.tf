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

# Region
provider "aws" {
  region = "eu-west-1"
}

# Modules
module "frontend" {
  source = "./frontend"
}

module "api" {
  source          = "./api"
  certificate_arn = module.domain_management.thomaskimble_certificate_validation_arn
}

module "domain_management" {
  source               = "./domain_management"
  regional_domain_name = module.api.thomaskimble_api_domain_name
  regional_zone_id     = module.api.thomaskimble_api_zone_id
}
