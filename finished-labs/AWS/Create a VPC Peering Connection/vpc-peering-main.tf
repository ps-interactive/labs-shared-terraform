# Cloud Labs: Create a VPC Peering Connection
#
# Created by Michael Bender
# Creates a Public VPC w/ Web Server and Private VPC w/ Database Server

# AWS Boilerplate
provider "aws" {
  version = "~> 2.0"
  region  = "us-west-2"
}

# Set Data for AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name = "owner-alias"
    values = [ "amazon" ]
  }
  filter {
    name = "name"
    values = ["amzn2-ami-hvm*"]
  }
  owners = ["137112412989"]
  
}

# Variable used in the creation of the `web-vpc_internet_access` resource
variable "cidr_block" {
    default = "0.0.0.0/0"
}

# Custom VPC shows the use of tags to name resources
# Instance Tenancy set to `default` is not to be confused with the concept of a Default VPC

resource "aws_vpc" "web-vpc" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"

  tags   = {
    Name = "web-vpc"
  }
}

# Create subnet webpub for 10.1.254.0/24
resource "aws_subnet" "web-pub" {
  vpc_id     = aws_vpc.web-vpc.id
  cidr_block = "10.1.254.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "web-pub"
  }
}

# Custom Internet Gateway - not created as part of the initialization of a VPC
resource "aws_internet_gateway" "web-igw" {
  vpc_id = aws_vpc.web-vpc.id

  tags = {
    Name = "web-igw"
  }
}

# Create Route Table
resource "aws_route_table" "web-pub" {
  vpc_id = aws_vpc.web-vpc.id

  tags = {
    Name = "web-pub"
  }
}

# Create Route Table Association
resource "aws_route_table_association" "web-pub-rta" {
  subnet_id      = aws_subnet.web-pub.id
  route_table_id = aws_route_table.web-pub.id
}


# Create a Route in the Main Routing Table - no need to create a Custom Routing Table
# Use `main_route_table_id` to pull the ID of the main routing table
resource "aws_route" "internet-igw" {
  route_table_id         = aws_route_table.web-pub.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.web-igw.id
}

# End here for Module 2 - Deploy a VPC

# Security allowing SSH and HTTP Inbound
resource "aws_security_group" "web-pub-sg" {
  name        = "web-pub-sg"
  description = "web-pub subnet sg"
  vpc_id      = aws_vpc.web-vpc.id

// SSH

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-pub-sg"
  }
}

# Create network interface - www1 eth0
resource "aws_network_interface" "eth0" {
  subnet_id      = aws_subnet.web-pub.id
  private_ips     = ["10.1.254.10"]
  security_groups = ["${aws_security_group.web-pub-sg.id}"]
}

# Private VPC
# Custom VPC shows the use of tags to name resources
# Instance Tenancy set to `default` is not to be confused with the concept of a Default VPC

resource "aws_vpc" "shared-vpc" {
  cidr_block       = "10.2.0.0/16"
  instance_tenancy = "default"

  tags   = {
    Name = "shared-vpc"
  }
}

# Create subnet webpub for 10.1.254.0/24
resource "aws_subnet" "database" {
  vpc_id     = aws_vpc.shared-vpc.id
  cidr_block = "10.2.2.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "database"
  }
}

# Create Route Table
resource "aws_route_table" "shared" {
  vpc_id = aws_vpc.shared-vpc.id

  tags = {
    Name = "shared"
  }
}

# Create Route Table Association
resource "aws_route_table_association" "shared-rta" {
  subnet_id      = aws_subnet.database.id
  route_table_id = aws_route_table.shared.id
}

# Security allowing SSH and HTTP Inbound
resource "aws_security_group" "database-sg" {
  name        = "database-sg"
  description = "Internal SSH"
  vpc_id      = aws_vpc.shared-vpc.id

// SSH

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "database-sg"
  }
}

# Create network interface - db1 eth0
resource "aws_network_interface" "eth0-db1" {
  subnet_id      = aws_subnet.database.id
  private_ips     = ["10.2.2.41"]
  security_groups = ["${aws_security_group.database-sg.id}"]
}

# EC2 Instances
#Public - ww1
resource "aws_instance" "www1" {
    ami                          = data.aws_ami.amazon_linux.id
    instance_type                = "t2.nano"
    monitoring                   = false
    #subnet_id                    = aws_subnet.web-pub.id
    tags                         = { Name = "www1" }
    #vpc_security_group_ids       = [aws_security_group.web-pub-sg.id]

     network_interface {
     network_interface_id = aws_network_interface.eth0.id
     device_index = 0
  }
}

resource "aws_instance" "db1" {
    ami                          = data.aws_ami.amazon_linux.id
    instance_type                = "t2.nano"
    monitoring                   = false
    network_interface {
     network_interface_id = aws_network_interface.eth0-db1.id
     device_index = 0
    }
    #subnet_id                    = aws_subnet.database.id
    tags                         = { Name = "db1" }
    #vpc_security_group_ids       = [aws_security_group.database-sg.id]
}
