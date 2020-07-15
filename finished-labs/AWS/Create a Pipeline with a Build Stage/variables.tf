provider "aws" {
  region = var.region
}

variable "region" {
  type = string
  default = "us-west-2"
}