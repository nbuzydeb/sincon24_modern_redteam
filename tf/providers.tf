terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = " 5.48.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}