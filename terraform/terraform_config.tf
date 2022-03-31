# Global Terraform
terraform {
  # providers
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8.0"
    }
  }

  # terraform version
  required_version = ">= 1.1.0"
}

provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "bucket-name"
    key    = "rotate.tfstate"
    region = "eu-west-1"
  }
}