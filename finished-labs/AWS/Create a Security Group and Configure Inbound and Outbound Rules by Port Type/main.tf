provider "aws" {
  version = "~> 2.0"
  region  = "us-west-2"
}

resource "aws_vpc" "lab_vpc" {
  cidr_block              = "10.0.1.0/24"

  tags = {
    Name = "lab-vpc"
  }
}

resource "aws_subnet" "lab_subnet" {
  vpc_id = "${aws_vpc.lab_vpc.id}"
  cidr_block              = "10.0.1.0/24"
  tags = {
    Name = "Lab Subnet"
  }
}
