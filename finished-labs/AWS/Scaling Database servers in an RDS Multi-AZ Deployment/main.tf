variable "region" {
  default = "us-west-2"
}

provider "aws" {
  version = "~> 2.6"
  region  = var.region
}

# Variable used in the creation of the `lab_vpc_internet_access` resource
variable "cidr_block" {
  default = "0.0.0.0/0"
}

# Custom VPC shows the use of tags to name resources
# Instance Tenancy set to `default` is not to be confused with the concept of a Default VPC
resource "aws_vpc" "lab_vpc" {
  cidr_block       = "10.0.0.0/26"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
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

# Create Private Route Table
resource "aws_route_table" "prv_route_table" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "Private Route Table"
  }
}

# Add a subnet to the VPC
resource "aws_subnet" "lab_vpc_subnet_pub_a" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.0.0/28"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
  tags = {
    Name = "Sub-Public-a"
  }
}

# Optional Subnets - make sure that the `cidr_block`s do not conflict
resource "aws_subnet" "lab_vpc_subnet_pub_b" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.0.16/28"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2b"
  tags = {
    Name = "Sub-Public-b"
  }
}

resource "aws_subnet" "lab_vpc_subnet_prv_a" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.0.32/28"
  map_public_ip_on_launch = false
  availability_zone       = "us-west-2a"
  tags = {
    Name = "Sub-Private-a"
  }
}

resource "aws_subnet" "lab_vpc_subnet_prv_b" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.0.48/28"
  map_public_ip_on_launch = false
  availability_zone       = "us-west-2b"
  tags = {
    Name = "Sub-Private-b"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.lab_vpc_subnet_prv_a.id
  route_table_id = aws_route_table.prv_route_table.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.lab_vpc_subnet_prv_b.id
  route_table_id = aws_route_table.prv_route_table.id
}
