terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {}

resource "aws_db_instance" "source" {
  allocated_storage    = 5
  engine               = "postgres"
  engine_version       = "13.2"
  identifier           = "my-source-db"
  instance_class       = "db.t3.micro"
  name                 = "mydb"
  username             = "fizz"
  password             = "buzzbarbazz"
  skip_final_snapshot  = true
}

resource "aws_security_group" "no_inbound" {
  name        = "no-inbound"
  description = "no inbound rules"
  vpc_id      = aws_default_vpc.default.id
}

resource "aws_default_vpc" "default" {
}
