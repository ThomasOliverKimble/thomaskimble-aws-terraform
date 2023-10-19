# Providers
terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.21.0"
    }
  }

  required_version = ">= 1.5.1"
}

# Region
provider "aws" {
  region = "eu-west-1"
}
