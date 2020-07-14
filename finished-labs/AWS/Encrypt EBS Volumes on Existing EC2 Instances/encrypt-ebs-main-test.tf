# Labs: Encrypt an Existing EBS Volume and EC2 Instance
#
# Created by Michael Bender
# June 10, 2020
# Updates: Added code to use most updated version of ubuntu image

# AWS Boilerplate
provider "aws" {
  version = "~> 2.0"
  region  = "us-west-2"
}

# Set Data
data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["099720109477"]
}

# Web1
# Create EC2 Instance of Web1
# Based off of standard AMI
resource "aws_instance" "web1" {
    ami                          = data.aws_ami.ubuntu.id
    associate_public_ip_address  = true
    instance_type                = "t2.micro"
    
    root_block_device {
        delete_on_termination = true
        encrypted             = false
        volume_size           = 10
    }
  volume_tags = {

      name = "ebs-web1-root"
  }

  tags = {
    Name = "web1"
  }

    timeouts {}
}

# Create EC2 Instance of data1 w/ added EBS volume
# Based off of standard AMI
resource "aws_instance" "data1" {
    ami                          = data.aws_ami.ubuntu.id
    associate_public_ip_address  = true
    instance_type                = "t2.micro"

 # Set root vol as encrypted
  root_block_device {
              volume_size = 8
              encrypted = true
              }
  
  # Add unencrypted EBS Volume
  ebs_block_device {
      device_name = "/dev/sdb"
      delete_on_termination = true
      volume_size = 12
      encrypted =  false
    }

  tags = {
    Name = "data1"
  }

    timeouts {}
}