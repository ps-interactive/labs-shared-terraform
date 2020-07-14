provider "aws" {
  region = var.region
}

variable "region" {
  type = string
  default = "us-west-2"
}

variable "availability_zones" {
  type = list(string)
  default = ["us-west-2a", "us-west-2b"]
}

variable "ec2_name" {
  type = string
  default = "amazon-linux-v2-web-server"
}

variable "instance_type" {
  type = string
  default = "t3.nano"
}

