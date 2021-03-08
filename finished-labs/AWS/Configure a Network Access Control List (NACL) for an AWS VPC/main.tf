# COMMON CONFIGURATION

provider "aws" {
  region = "us-west-2"
}

# CUSTOM VPC CREATION

# Variable used in the creation of the `lab_vpc_internet_access` resource
variable "cidr_block" {
  default = "0.0.0.0/0"
}

# Custom VPC shows the use of tags to name resources
# Instance Tenancy set to `default` is not to be confused with the concept of a Default VPC
resource "aws_vpc" "lab_vpc" {
  cidr_block       = "172.11.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Pluralsight-AWS-LAB"
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
  cidr_block              = "172.11.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "AWS-Lab-Subnet-A"
  }
}

resource "aws_subnet" "lab_vpc_subnet_b" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "172.11.10.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "AWS-Lab-Subnet-B"
  }
}

resource "aws_subnet" "lab_vpc_subnet_c" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "172.11.20.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "AWS-Lab-Subnet-C"
  }
}


#SECURITY GROUP DECLARATION

resource "aws_security_group" "websg" {
  name = "terraform-webserver-websg"
  vpc_id = aws_vpc.lab_vpc.id

  ingress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

}

# SUBNET A SERVER DEFINITION

resource "aws_instance" "webserverA1"{
  ami = "ami-0e999cbd62129e3b1"
#  key_name = "test_aws_lab_nacl"
  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.lab_vpc_subnet_a.id
  vpc_security_group_ids = ["${aws_security_group.websg.id}"]

  tags = {
    Name = "Server-A1"
  }

  user_data     = <<-EOF
                  #!/bin/bash
                  sudo su
                  echo "<html><body><h1>Welcome to Pluralsight AWS LAB <br> This Service runs on TCP port = 80 <br> This is Server-A1 </h1></body></html>" | sudo tee /home/ec2-user/index.html
                  python -m SimpleHTTPServer 80

                 EOF
}

resource "aws_instance" "webserverA2"{
  ami = "ami-0e999cbd62129e3b1"
#  key_name = "test_aws_lab_nacl"
  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.lab_vpc_subnet_a.id
  vpc_security_group_ids = ["${aws_security_group.websg.id}"]

  tags = {
    Name = "Server-A2"
  }

  user_data     = <<-EOF
                  #!/bin/bash
                  sudo su
                  echo "<html><body><h1>Welcome to Pluralsight AWS LAB <br> This Service runs on TCP port = 8080 <br> This is Server-A2 </h1></body></html>" | sudo tee /home/ec2-user/index.html
                  python -m SimpleHTTPServer 8080

                 EOF
}


#SUBNET B SERVER DEFINITION

resource "aws_instance" "webserverB1"{
  ami = "ami-0e999cbd62129e3b1"
#  key_name = "test_aws_lab_nacl"
  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.lab_vpc_subnet_b.id
  vpc_security_group_ids = ["${aws_security_group.websg.id}"]

  tags = {
    Name = "Server-B1"
  }

  user_data     = <<-EOF
                  #!/bin/bash
                  sudo su
                  echo "<html><body><h1>Welcome to Pluralsight AWS LAB <br> This Service runs on TCP port = 80 <br> This is Server-B1 </h1></body></html>" | sudo tee /home/ec2-user/index.html
                  python -m SimpleHTTPServer 80

                 EOF
}


resource "aws_instance" "webserverB2"{
  ami = "ami-0e999cbd62129e3b1"
#  key_name = "test_aws_lab_nacl"
  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.lab_vpc_subnet_b.id
  vpc_security_group_ids = ["${aws_security_group.websg.id}"]

  tags = {
    Name = "Server-B2"
  }

  user_data     = <<-EOF
                  #!/bin/bash
                  sudo su
                  echo "<html><body><h1>Welcome to Pluralsight AWS LAB <br> This Service runs on TCP port = 8080 <br> This is Server-B2 </h1></body></html>" | sudo tee /home/ec2-user/index.html
                  python -m SimpleHTTPServer 8080

                 EOF
}

#SUBNET C DEFINITION

resource "aws_instance" "webserverC1"{
  ami = "ami-0e999cbd62129e3b1"
#  key_name = "test_aws_lab_nacl"
  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.lab_vpc_subnet_c.id
  vpc_security_group_ids = ["${aws_security_group.websg.id}"]

  tags = {
    Name = "Server-C1"
  }

  user_data     = <<-EOF
                  #!/bin/bash
                  sudo su
                  echo "<html><body><h1>Welcome to Pluralsight AWS LAB <br> This Service runs on TCP port = 80 <br> This is Server-C1 </h1></body></html>" | sudo tee /home/ec2-user/index.html
                  python -m SimpleHTTPServer 80

                 EOF
}

resource "aws_instance" "webserverC2"{
  ami = "ami-0e999cbd62129e3b1"
#  key_name = "test_aws_lab_nacl"
  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.lab_vpc_subnet_c.id
  vpc_security_group_ids = ["${aws_security_group.websg.id}"]

  tags = {
    Name = "Server-C2"
  }

  user_data     = <<-EOF
                  #!/bin/bash
                  sudo su
                  echo "<html><body><h1>Welcome to Pluralsight AWS LAB <br> This Service runs on TCP port = 8080 <br> This is Server-C2 </h1></body></html>" | sudo tee /home/ec2-user/index.html
                  python -m SimpleHTTPServer 8080

                 EOF
}


# ROLE AND POLICY DEFINITION

resource "aws_iam_policy" "policy" {
  name        = "policy"
  description = "IAM Policy for XXX nodes"
  policy      = "${file("policy.json")}"
}

resource "aws_iam_role" "ec2_role" {
  name               = "ec2_role"
  assume_role_policy = "${file("ec2_assumerolepolicy.json")}"
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role       = "${aws_iam_role.ec2_role.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name  = "instance_profile"
  role = "${aws_iam_role.ec2_role.name}"
}

output "public_ip1" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = aws_instance.webserverA1.*.public_ip
}

output "public_ip_2" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = aws_instance.webserverB1.*.public_ip
}

output "public_ip_3" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = aws_instance.webserverC1.*.public_ip
}

output "public_ip4" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = aws_instance.webserverA2.*.public_ip
}

output "public_ip_5" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = aws_instance.webserverB2.*.public_ip
}

output "public_ip_6" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = aws_instance.webserverC2.*.public_ip
}

