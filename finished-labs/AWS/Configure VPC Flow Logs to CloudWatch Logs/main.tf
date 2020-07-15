provider "aws" {
  region  = "us-west-2"
  

}

data "aws_ami" "amazon-linux-2" {
 most_recent = true
 owners = ["137112412989"]


 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }

 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}


locals {
 instance-userdata = <<EOF
 
 #!/bin/bash
yum update -y
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum install -y httpd mariadb-server
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
 
EOF

}
# create the VPC

resource "aws_vpc" "Globo_VPC" {
  cidr_block           = "10.0.0.0/16"
 
tags = {
    Name = "GloboVPC"
}
} 

# end resource

# create the Subnet

resource "aws_subnet" "Globo_VPC_Subnet" {
  vpc_id                  = aws_vpc.Globo_VPC.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
tags = {
   Name = "Globo VPC Subnet"
}
} 

# end resource

# Create the Security Group

resource "aws_security_group" "Globo_VPC_Security_Group" {
  vpc_id       = aws_vpc.Globo_VPC.id
  name         = "Globo VPC Security Group"
  description  = "Globo VPC Security Group"
  
  # allow ingress of port 80
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 80
    protocol    = "tcp"
  } 
  
  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
   Name = "Globo VPC Security Group"
   Description = "Globo VPC Security Group"
}
} 

# end resource

# Create the Internet Gateway

resource "aws_internet_gateway" "Globo_VPC_GW" {
 vpc_id = aws_vpc.Globo_VPC.id
 tags = {
        Name = "Globo VPC Internet Gateway"
}
} 

# end resource

# Create the Route Table

resource "aws_route_table" "Globo_VPC_route_table" {
 vpc_id = aws_vpc.Globo_VPC.id
 tags = {
        Name = "Globo VPC Route Table"
}
} 

# end resource

# Create the Internet Access
resource "aws_route" "Globo_VPC_internet_access" {
  route_table_id         = aws_route_table.Globo_VPC_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.Globo_VPC_GW.id
} 

# end resource

# Associate the Route Table with the Subnet

resource "aws_route_table_association" "Globo_VPC_association" {
  subnet_id      = aws_subnet.Globo_VPC_Subnet.id
  route_table_id = aws_route_table.Globo_VPC_route_table.id
} 

# end resource


# Create EC2 Instance

resource "aws_instance" "example" {
  ami = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.Globo_VPC_Subnet.id
  vpc_security_group_ids = [aws_security_group.Globo_VPC_Security_Group.id]
  tags = {
	Name = "Webserver1"
  } 
  user_data_base64 = base64encode(local.instance-userdata)
}

# end resource


