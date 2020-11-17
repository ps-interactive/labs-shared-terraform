variable "project_name" {
  type        = string
  default     = "Demo"
  description = "Project name for tagging purposes"
}

variable "environment" {
  type        = string
  default     = "Dev"
  description = "Environment name for tagging purposes"
}

variable "db_port" {
  type        = number
  description = "Comes from networking template"
}

variable "vpc" {
  type        = string
  description = "Comes from networking template"
}

variable "private_subnets" {
  type        = list
  description = "Comes from networking template"
}

variable "public_subnets" {
  type        = list
  description = "Comes from networking template"
}

variable "db_subnets" {
  type        = list
  description = "Comes from networking template"
}

variable "db_subnet_group" {
  type        = string
  description = "Comes from networking template"
}

variable "db_engine" {
  type        = string
  default     = "postgres"
  description = "DB engine being used"
}

variable "db_version" {
  type        = string
  default     = "12.4"
  description = "DB engine being used"
}

variable "db_user" {
  type        = string
  default     = "dbsuper"
  description = "Superuser username"
}

data "aws_ssm_parameter" "amazon_linux_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

locals {
  name_tag_prefix   = "${var.project_name}-${var.environment}"
}
