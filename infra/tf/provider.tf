terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40"
    }
  }

  required_version = ">= 1.7.0"

  backend "s3" {
    bucket         = "cafetech-terraform"
    key            = "default/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "cafetech-terraform"
  }
}

provider "aws" {
  region = "us-west-2"

  default_tags {
   tags = {
     IAC       = "Terraform"
   }
 }
}
