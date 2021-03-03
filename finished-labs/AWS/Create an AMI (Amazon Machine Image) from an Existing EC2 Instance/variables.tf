provider "aws" {
  region = var.region
}

variable "region" {
  type = string
  default = "us-west-2"
}

variable "availability_zones" {
  type = list(string)
  default = ["us-west-2a"]
}

variable "ec2_name" {
  type = string
  default = "web-server"
}

variable "instance_type" {
  type = string
  default = "t3.nano"
}

