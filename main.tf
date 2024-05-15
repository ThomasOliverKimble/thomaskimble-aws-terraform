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
  source = "./api"
}

module "domain_management" {
  source = "./domain_management"
}
