# vpc.tf

resource "aws_internet_gateway" "web-igw" {
  vpc_id = aws_vpc.lab_vpc.id
}

resource "aws_vpc" "lab_vpc" {
  cidr_block       = "172.31.0.0/16"
  instance_tenancy = "default"
}

resource "aws_subnet" "subnets" {
  for_each                = var.subnets
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = each.value
  map_public_ip_on_launch = true
  availability_zone       = each.key
}