provider "aws" {
  version    = "~> 2.0"
  region     = "us-west-2"
}

resource "aws_vpc" "terra_vpc" {
  assign_generated_ipv6_cidr_block = false
  cidr_block                       = "10.0.0.0/16"
  instance_tenancy                 = "default"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  tags = {
    Name = "My_VPC_Terra"
  }
}
# Internet gateway
resource "aws_internet_gateway" "terra_igw" {
  vpc_id = aws_vpc.terra_vpc.id
  tags = {
    Name = "IGW_Terra_VPC"
  }
}
# Define a Public Subnets
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.terra_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  tags = {
     Name = "Public-west-2a"
  }
}

# Define the New route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.terra_vpc.id
  route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.terra_igw.id
  }
  tags = {
   Name = "Pub_RT_Terra"
   }
}

# Assign the route table to the Public Subnet
resource "aws_route_table_association" "public_rt" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Define the security group for public subnet (Allow ssh)
resource "aws_security_group" "pubsg" {
  name = "vpc_test_pub"
  description = "Allow incoming SSH access"

   ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
   }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
   vpc_id = aws_vpc.terra_vpc.id
   tags = {
     Name = "New PubSG Terra"
   }
}
data "aws_ssm_parameter" "amazon_linux_ami" {
    name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "AmazonLinux1" {
    ami                          = data.aws_ssm_parameter.amazon_linux_ami.value
    instance_type                = "t2.micro"
    associate_public_ip_address  = true
    availability_zone            = "us-west-2a"
    monitoring                   = false
    subnet_id                    = aws_subnet.public_subnet.id
    vpc_security_group_ids       = [aws_security_group.pubsg.id]
    root_block_device {
        delete_on_termination = true
        encrypted             = false
        iops                  = 100
        volume_size           = 10
        volume_type           = "gp2"
    }
    tags = {
        Name = "Linux1"
    }
}
resource "aws_instance" "AmazonLinux2" {
    ami                          = data.aws_ssm_parameter.amazon_linux_ami.value
    instance_type                = "t2.micro"
    associate_public_ip_address  = true
    availability_zone            = "us-west-2a"
    monitoring                   = false
    subnet_id                    = aws_subnet.public_subnet.id
    vpc_security_group_ids       = [aws_security_group.pubsg.id]
    root_block_device {
        delete_on_termination = true
        encrypted             = false
        iops                  = 100
        volume_size           = 10
        volume_type           = "gp2"
    }
    tags = {
        Name = "Linux2"
    }
}
