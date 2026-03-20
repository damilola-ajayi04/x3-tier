# Terraform Backend

terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "x3-tier-terraform-state"
    key            = "terraform/3tier.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "x3-terraform-state-lock"
    encrypt        = true
  }
}

# Provider

provider "aws" {
  region = "eu-west-2"
}