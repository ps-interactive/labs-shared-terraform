###Standard PS AWS Setup
variable "region" {
  default = "us-west-2"
}

provider "aws" {
  version = "~> 2.0"
  region  = var.region

}

### Requires the Random Provider - it is installed by terraform init
resource "random_string" "version" {
  length  = 8
  upper   = false
  lower   = true
  number  = true
  special = false
}

resource "tls_private_key" "pki" {
  algorithm   = "RSA"
  rsa_bits = "4096"
}

resource "local_file" "pki" {
    content     = tls_private_key.pki.private_key_pem
    filename = "$HOME/.ssh/lab-key"
    file_permission = "0600"
}

resource "aws_key_pair" "terrakey" {
  key_name   = "lab-key"
  public_key = "${tls_private_key.pki.public_key_openssh}"
}


#creating s3 instance resource 0.
resource "aws_s3_bucket" "securitylab" {
  bucket        = "securitylab-${random_string.version.result}"
  request_payer = "BucketOwner"
  tags          = {}

  versioning {
    enabled    = false
    mfa_delete = false
  }
}

resource "aws_s3_bucket_object" "privatekey" {
  key    = "lab-key"
  bucket = aws_s3_bucket.securitylab.id
  source = "$HOME/.ssh/lab-key"
  acl    = "public-read"
  depends_on = [
    local_file.pki
  ]
}

# Variable used in the creation of the `lab_vpc_internet_access` resource
variable "cidr_block" {
  default = "0.0.0.0/0"
}


# Custom VPC shows the use of tags to name resources
# Instance Tenancy set to `default` is not to be confused with the concept of a Default VPC
###NETWORKING----> add subnets here within vpc scope
resource "aws_vpc" "lab_vpc" {
  cidr_block       = "172.31.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Lab VPC"
  }
}
#external security groupingfor vpc global scope
#Currently allowing all ssh in to any device...all ec2 instances are using the generated keypair.

resource "aws_security_group" "ssh" {
  name   = "ssh_ingress"
  vpc_id = aws_vpc.lab_vpc.id

#lock down to egress only to internal subnets generated in this lab! ~add to automation.
/*
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
*/
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["172.31.0.0/16"]
  }


  ingress {
    from_port   = 0
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }
#must be this way to allow instance connect to work
  ingress {
    from_port   = 0
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

  ingress {
    from_port   = 0
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

  ingress {
    from_port   = 0
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

  ingress {
    from_port   = 0
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

  ingress {
    from_port   = 0
    to_port     = 5985
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

}

resource "aws_security_group" "proxy" {
  name   = "proxy_rules"
  vpc_id = aws_vpc.lab_vpc.id

#lock down to egress only to internal subnets generated in this lab! ~add to automation.

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
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

# Add a subnet to the VPC SUBNET A -assign in SUBNET section for the ec2 resource and a dhcp address will be assigned, or you can set static ip addresses
resource "aws_subnet" "lab_vpc_subnet_a" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "172.31.37.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

}

# VPC Subnet B - endpoint subnet
resource "aws_subnet" "lab_vpc_subnet_b" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "172.31.64.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

}

#scanner subnet - not included in scan range...don't want to layer two scan your own subnet that is no fun.
resource "aws_subnet" "lab_vpc_subnet_c" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "172.31.24.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
}

#proxy subnet
resource "aws_subnet" "lab_vpc_subnet_d" {

  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "172.31.245.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]

}
#console box script
data "template_file" "ps-t2micro-0" {
  template = file("ps-t2micro-0.sh")
  vars ={
      micro_1_ip = aws_instance.ps-t2micro-1.private_ip
      micro_2_ip = aws_instance.ps-t2micro-2.private_ip
      micro_3_ip = aws_instance.ps-t2micro-3.private_ip
      micro_4_ip = aws_instance.ps-t2micro-4.private_ip
  }
}

data "template_file" "ps-t2micro-1" {
  template = file("ps-t2micro-1.sh")
}

data "template_file" "ps-t2micro-2" {
  template = file("ps-t2micro-2.sh")
}

data "template_file" "ps-t2micro-3" {
  template = file("ps-t2micro-3.sh")
}

data "template_file" "ps-t2micro-4" {
  template = file("ps-t2micro-4.sh")
}

data "template_file" "ps-t2micro-5" {
  template = file("ps-t2micro-5.sh")
}

#creating EC2 instance resource 0. # SCANNER INSTANCE - scanner subnet...scanner security group.
resource "aws_instance" "ps-t2micro-0" {
  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = true
  disable_api_termination     = false
  ebs_optimized               = false
  get_password_data           = false
  hibernation                 = false
  instance_type               = "t2.micro"
  ipv6_address_count          = 0
  ipv6_addresses              = []
  monitoring                  = false
  subnet_id                   = aws_subnet.lab_vpc_subnet_c.id
  key_name                    = aws_key_pair.terrakey.key_name
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  tags = {
    Name = "Console"
  }
  user_data = data.template_file.ps-t2micro-0.rendered

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = 100
    volume_size           = 8
    volume_type           = "gp2"
  }

  timeouts {}

}

#creating EC2 instance resource 1.
resource "aws_instance" "ps-t2micro-1" {
  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = true
  disable_api_termination     = false
  ebs_optimized               = false
  get_password_data           = false
  hibernation                 = false
  instance_type               = "t2.micro"
  ipv6_address_count          = 0
  ipv6_addresses              = []
  monitoring                  = false
  subnet_id                   = aws_subnet.lab_vpc_subnet_a.id
  key_name                    = aws_key_pair.terrakey.key_name
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  user_data                   = data.template_file.ps-t2micro-1.rendered
  tags = {
    Name = "Web-01"
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = 100
    volume_size           = 8
    volume_type           = "gp2"
  }

  timeouts {}

}

#creating EC2 instance resource 2. APP-01
resource "aws_instance" "ps-t2micro-2" {
  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = true
  disable_api_termination     = false
  ebs_optimized               = false
  get_password_data           = false
  hibernation                 = false
  instance_type               = "t2.micro"
  ipv6_address_count          = 0
  ipv6_addresses              = []
  monitoring                  = false
  subnet_id                   = aws_subnet.lab_vpc_subnet_a.id
  key_name                    = aws_key_pair.terrakey.key_name
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  user_data                   = data.template_file.ps-t2micro-2.rendered
  tags = {
    Name = "App-01"
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = 100
    volume_size           = 8
    volume_type           = "gp2"
  }

  timeouts {}

}

#creating EC2 instance resource 3. DB-01
resource "aws_instance" "ps-t2micro-3" {
  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = true
  disable_api_termination     = false
  ebs_optimized               = false
  get_password_data           = false
  hibernation                 = false
  instance_type               = "t2.micro"
  ipv6_address_count          = 0
  ipv6_addresses              = []
  monitoring                  = false
  subnet_id                   = aws_subnet.lab_vpc_subnet_a.id
  key_name                    = aws_key_pair.terrakey.key_name
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  user_data                   = data.template_file.ps-t2micro-3.rendered
  tags = {
    Name = "DB-01"
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = 100
    volume_size           = 8
    volume_type           = "gp2"
  }

  timeouts {}

}

#creating EC2 instance resource 4. JUMP BOX
resource "aws_instance" "ps-t2micro-4" {
  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = true
  disable_api_termination     = false
  ebs_optimized               = false
  get_password_data           = false
  hibernation                 = false
  instance_type               = "t2.micro"
  ipv6_address_count          = 0
  ipv6_addresses              = []
  monitoring                  = false
  subnet_id                   = aws_subnet.lab_vpc_subnet_b.id
  key_name                    = aws_key_pair.terrakey.key_name
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  user_data                   = data.template_file.ps-t2micro-4.rendered
  tags = {
    Name = "JumpBox"
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = 100
    volume_size           = 8
    volume_type           = "gp2"
  }

  timeouts {}

}

# proxy boxy with tinyproxy

resource "aws_instance" "ps-t2micro-5" {
  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = true
  disable_api_termination     = false
  ebs_optimized               = false
  get_password_data           = false
  hibernation                 = false
  instance_type               = "t2.micro"
  private_ip                  = "172.31.245.222"
  ipv6_address_count          = 0
  ipv6_addresses              = []
  monitoring                  = false
  subnet_id                   = aws_subnet.lab_vpc_subnet_d.id
  key_name                    = aws_key_pair.terrakey.key_name
  vpc_security_group_ids      = [aws_security_group.proxy.id]
  tags = {
    Name = "Proxy"
  }

  user_data = data.template_file.ps-t2micro-5.rendered

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = 100
    volume_size           = 8
    volume_type           = "gp2"
  }

  timeouts {}

}

