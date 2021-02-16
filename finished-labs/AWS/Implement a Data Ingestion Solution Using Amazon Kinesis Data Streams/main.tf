provider "aws" {
  version = "~> 2.0"
  region  = "us-west-2"
}


data "aws_vpc" "default" {
    default = true
}

data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group" "pluralsight" {
    name_prefix = "pluralsight-"
    vpc_id = data.aws_vpc.default.id
    tags = {
        Description = "my description here"
    }
}

resource "aws_security_group_rule" "allow_local_http" {
    type = "ingress"
    protocol = "tcp"
    from_port = 80
    to_port = 80
    # cidr_blocks = [data.aws_vpc.default.cidr_block]
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.pluralsight.id
}

# TODO REMOVE BEFORE SUBMIT
resource "aws_security_group_rule" "allow_ssh" {
    type = "ingress"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.pluralsight.id
}


resource "aws_security_group_rule" "allow_egress" {
    type = "egress"
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.pluralsight.id
}

data "aws_ami" "amazon_linux_2" {

  # set most_recent to true to always pull the latest version
  most_recent = true

  # this filter is where you put that text from the AMI Name that you found in step 2.  Add a * after that base name as a wildcard so that you’re not ever searching for a specific version number
  filter {
    name = "name"
    values = ["amzn2-ami-hvm*"]
  }

  # this owners field is required, and you’ll need to include in quotes whatever owner you uncovered for your image in step 3.
  owners = ["amazon"]
}

resource "aws_instance" "myfirstec2" {
	ami = data.aws_ami.amazon_linux_2.id
	instance_type = "t2.micro"
	vpc_security_group_ids = [aws_security_group.pluralsight.id]
	user_data = <<-EOF
		    #!/bin/bash
            sudo yum update -y
            sudo yum -y install python-pip
		    sudo pip install boto
		    sudo pip install testdata
		    EOF	
	tags = {
   		 Name = "PluralSightAnalyticsEngine"
  		}			
}



