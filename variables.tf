variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "x3-tier"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_app_subnet_cidr" {
  description = "CIDR block for app subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_db_subnet_cidr" {
  description = "CIDR block for DB subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "availability_zone" {
  description = "Availability Zone"
  type        = string
  default     = "eu-west-2a"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-087c9ba923d9765d8"
}

variable "instance_type" {
  description = "Instance type for all tiers"
  type        = string
  default     = "t2.micro"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access (restrict to your IP)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "state_bucket_name" {
  description = "S3 bucket for Terraform state"
  type        = string
  default     = "x3-tier-terraform-state"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table for state locking"
  type        = string
  default     = "terraform-state-lock"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)

  default = {
    Project     = "x3-tier"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}