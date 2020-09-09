provider "aws" {
  version = "~> 2.0"
  region  = "us-west-2"
}


variable "mime_types" {
  default = {
    txt  = "text/plain"
    html = "text/html"
  }
}


resource "random_string" "bucket_name" {
  length  = 8
  upper   = false
  lower   = true
  number  = true
  special = false
}


resource "aws_s3_bucket" "lab_resources" {
  bucket = "lab-resources-${random_string.bucket_name.result}"
  acl    = "private"
}




data "aws_ami" "amazon_linux_2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


data "aws_vpc" "default" { default = true }
data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id

  filter {
    name   = "group-name"
    values = ["default"]
  }
}




resource "aws_security_group" "ssh1" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh2" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "instance1" {
  ami                    = data.aws_ami.amazon_linux_2.image_id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ssh1.id]
  tags = {
    Environment = "Development"
  }
}

resource "aws_instance" "instance2" {
  ami                    = data.aws_ami.amazon_linux_2.image_id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ssh2.id]
  tags = {
    Environment = "Production"
  }
}
