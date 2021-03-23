terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.26"
    }
  }
}

provider "aws" {
  region  = "us-west-2"
}