variable "region" {
  default = "us-west-2"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "availability_zones" {
  type = list(string)
  default = ["us-west-2a", "us-west-2b"]
}

data "aws_ami" "amazon_linux_v2" {
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-2*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Amazon

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
  cidr_block           = "10.0.0.0/26"
  instance_tenancy     = "default"
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

# Add a subnet to the VPC
resource "aws_subnet" "lab_vpc_subnet_pub_a" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.0.0/28"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
  tags = {
    Name = "public-subnet-a"
  }
}

# Optional Subnets - make sure that the `cidr_block`s do not conflict
resource "aws_subnet" "lab_vpc_subnet_pub_b" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.0.16/28"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2b"
  tags = {
    Name = "public-subnet-b"
  }
}

resource "aws_security_group" "lab_user_access" {
  name = "lab-user-access"
  vpc_id = aws_vpc.lab_vpc.id

  ingress {
    description = "HTTP from the world"
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    self = true
  }

  egress {
    description = "Unrestricted"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_a" {
  ami = data.aws_ami.amazon_linux_v2.id
  instance_type = var.instance_type
  user_data = file("install_carved_rock_site.sh")
  vpc_security_group_ids = [aws_security_group.lab_user_access.id]
  subnet_id= aws_subnet.lab_vpc_subnet_pub_a.id
  tags = {
    Name = "ps-web-instance-a"
  }
}
resource "aws_instance" "web_b" {
  ami = data.aws_ami.amazon_linux_v2.id
  instance_type = var.instance_type
  user_data = file("install_carved_rock_site.sh")
  vpc_security_group_ids = [aws_security_group.lab_user_access.id]
  subnet_id= aws_subnet.lab_vpc_subnet_pub_b.id

  tags = {
    Name = "ps-web-instance-b"
  }
}
