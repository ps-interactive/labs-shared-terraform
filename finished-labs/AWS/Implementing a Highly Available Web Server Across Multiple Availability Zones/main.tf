# Variable used in the creation of the `lab_vpc_internet_access` resource
variable "cidr_block" {
  default = "0.0.0.0/0"
}

# Custom VPC shows the use of tags to name resources
# Instance Tenancy set to `default` is not to be confused with the concept of a Default VPC
resource "aws_vpc" "lab_vpc" {
  cidr_block       = "172.31.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Pluralsight Lab VPC"
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
  cidr_block              = "172.31.48.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
}

# Optional Subnets - make sure that the `cidr_block`s do not conflict
resource "aws_subnet" "lab_vpc_subnet_b" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "172.31.16.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2b"
}

resource "aws_subnet" "lab_vpc_subnet_c" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "172.31.0.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2c"
}

resource "aws_subnet" "lab_vpc_subnet_d" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "172.31.32.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2d"
}
