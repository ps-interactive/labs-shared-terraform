### PROVIDER ###
provider "aws" {
  region = "us-west-2"
  version = "~> 3.4"
  # profile    = "ps"
}

### VARIABLES ###
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "internet_cidr" {
  default = "0.0.0.0/0"
}

variable "common_name" {
  default = "create-custom-cloudtrail-trail"
}

### S3 ###
resource "aws_s3_bucket" "main" {
  bucket_prefix = "bucket-to-monitor"
  acl           = "private"
}

### VPC ###
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.common_name}-vpc"
  }
}

resource "aws_route" "main" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  availability_zone       = element(data.aws_availability_zones.main.names, 0)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.common_name}-subnet"
  }
}

data "aws_availability_zones" "main" {
  state = "available"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.common_name}-ig"
  }
}
