# Backend
terraform {
  backend "s3" {}
}

# Region
provider "aws" {
  region = "eu-west-1"
}
