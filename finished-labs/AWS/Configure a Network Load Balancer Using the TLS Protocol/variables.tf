# variables.tf

variable "region" {
  type = string
  default = "us-west-2"
}

variable "subnets" {
  type = map
  default = {
    us-west-2a = "172.31.1.0/24"
    us-west-2b = "172.31.2.0/24"
  }
}

variable "first_tier_name" {
  type = string
  default = "web-server-first-tier"
}

variable "second_tier_name" {
  type = string
  default = "web-server-second-tier"
}

variable "instance_type" {
  type = string
  default = "t3.nano"
}

variable "forwarding_port" {
  default = {
    "80"  = "TCP"
  }
}