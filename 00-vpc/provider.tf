terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.98.0"
    }
  }

backend "s3" {
  bucket         = "roboshop-remote-state-dev-1"
  key            = "roboshop-dev-vpc"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-locks-dev"
}
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}