# Global Terraform
terraform {
  # providers
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82.2"
    }
  }

  # terraform version
  required_version = "~> 1.2.0"
}

provider "aws" {
  region = "<region>"
}

terraform {
  backend "s3" {
    bucket = "<bucket-name>"
    key    = "rotate.tfstate"
    region = "<region>"
  }
}