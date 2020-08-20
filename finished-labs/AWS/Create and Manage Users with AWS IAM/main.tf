


# Variable used in the creation of the `lab_vpc_internet_access` resource
variable "cidr_block" {
    default = "0.0.0.0/0"
}


variable "region" {
default = "us-west-2"
}

provider "aws" {
  version = "~> 2.0"
  region     = var.region
}

# Requires the `Random` Provider - it is installed by `terraform init`
resource "random_string" "version" {
  length  = 8
  upper   = false
  lower   = true
  number  = true
  special = false
}

# Custom VPC shows the use of tags to name resources
# Instance Tenancy set to `default` is not to be confused with the concept of a Default VPC

resource "aws_vpc" "lab_vpc" {
  cidr_block       = "172.31.0.0/16"
  instance_tenancy = "default"

  tags   = {
    Name = "Lab VPC"
  }
}

# Custom Internet Gateway - not created as part of the initialization of a VPC

resource "aws_internet_gateway" "lab_vpc_gateway" {
  vpc_id = aws_vpc.lab_vpc.id
}

# Create a Route in the Main Routing Table - no need to create a Custom Routing Table
# Use `main_route_table_id` to pull the ID of the main routing table

resource "aws_route" "lab_vpc_internet_access" {
  route_table_id         = aws_vpc.lab_vpc.main_route_table_id
  destination_cidr_block = var.cidr_block
  gateway_id             = aws_internet_gateway.lab_vpc_gateway.id
}

# Add a subnet to the VPC
resource "aws_subnet" "lab_vpc_subnet_a" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "172.31.37.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
}


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



resource "aws_instance" "ec2-test" {
    ami                          = data.aws_ami.ubuntu.id
    associate_public_ip_address  = true
    disable_api_termination      = false
    ebs_optimized                = false
    get_password_data            = false
    hibernation                  = false
    instance_type                = "t2.micro"
    ipv6_address_count           = 0
    ipv6_addresses               = []
    monitoring                   = false
    private_ip                   = "172.31.37.38"
    subnet_id                    = aws_subnet.lab_vpc_subnet_a.id


    timeouts {}
}

resource "aws_s3_bucket" "s3-test" {
    bucket                      = "sensitive-globo-bucket-${random_string.version.result}"
    request_payer               = "BucketOwner"
    tags                        = {}

    versioning {
        enabled    = false
        mfa_delete = false
    }
}