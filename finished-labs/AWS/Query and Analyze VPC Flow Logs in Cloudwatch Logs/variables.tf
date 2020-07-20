provider "aws" {
  region = var.region
}

variable "region" {
  type = string
  default = "us-west-2"
}

variable "availability_zones" {
  type = list(string)
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "ec2_name" {
  type = string
  default = "WebServer"
}

variable "instance_type" {
  type = string
  default = "t3.nano"
}

