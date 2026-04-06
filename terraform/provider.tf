# Terraform Backend

terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  #backend "s3" {
   # bucket         = "x3-tier-terraform-state"
   # key            = "terraform/3tier.tfstate"
   # region         = "eu-west-2"
   # dynamodb_table = "x3-terraform-state-lock"
   # encrypt        = true
  }
#}

# Provider

provider "aws" {
  region = "eu-west-2"
}

  resource "aws_s3_bucket" "tf_state" {
  bucket = "x3-tier-terraform-state"
}

resource "aws_dynamodb_table" "tf_lock" {
  name         = "x3-terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }


  tags = var.common_tags
}

