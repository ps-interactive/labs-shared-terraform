variable "region" {
    default = "us-west-2"
}

provider "aws" {
    version = "~> 2.0"
    region  = var.region
}

# Requires the Random Provider - it is installed by terraform init
resource "random_string" "version" {
    length  = 8
    upper   = false
    lower   = true
    number  = true
    special = false
}


# Variable used in the creation of the `lab_vpc_internet_access` resource
variable "cidr_block" {
    default = "0.0.0.0/0"
}

# Custom VPC shows the use of tags to name resources
# Instance Tenancy set to `default` is not to be confused with the concept of a Default VPC

resource "aws_vpc" "lab_vpc" {
  cidr_block       = "172.31.0.0/16"
  instance_tenancy = "default"

  tags   = {
    Name = "Lab VPC"
  }
}

resource "aws_security_group" "ssh" {
  name = "ssh_ingress"
  vpc_id = aws_vpc.lab_vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "22"
    to_port   = "22"
    protocol  = "tcp"

    # To keep this example simple, we allow incoming SSH requests from any IP. In real-world usage, you should only
    # allow SSH requests from trusted servers, such as a bastion host or VPN server.
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

# Add a subnet to the VPC
resource "aws_subnet" "lab_vpc_subnet_a" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "172.31.37.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
  
}


data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]

}

resource "aws_vpc" "vpc-0" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"
}

resource "aws_subnet" "subnet-0" {
  vpc_id     = aws_vpc.vpc-0.id
  cidr_block = "10.1.254.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
}

resource "aws_network_interface" "privates-0" {
  subnet_id      = aws_subnet.subnet-0.id
}

resource "aws_vpc" "vpc-1" {
  cidr_block       = "10.2.0.0/16"
  instance_tenancy = "default"
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.vpc-1.id
  cidr_block = "10.2.2.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
}

resource "aws_network_interface" "privates-1" {
  subnet_id      = aws_subnet.subnet-1.id
}

#creating EC2 instance resource 0.
resource "aws_instance" "ps-t2micro-0" {
    ami                          = data.aws_ami.ubuntu.id
    disable_api_termination      = false
    ebs_optimized                = false
    get_password_data            = false
    hibernation                  = false
    instance_type                = "t2.micro"
    monitoring                   = false
    user_data = data.template_file.action1.rendered
    tags = {
        Name = "Web-01"
    }
    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.privates-0.id
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
#creating EC2 instance resource 1.
resource "aws_instance" "ps-t2micro-1" {
    ami                          = data.aws_ami.ubuntu.id
    disable_api_termination      = false
    ebs_optimized                = false
    get_password_data            = false
    hibernation                  = false
    instance_type                = "t2.micro"
    monitoring                   = false
    user_data = data.template_file.action2.rendered
    tags = {
        Name = "Web-02"
    }
    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.privates-1.id
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
#creating EC2 instance resource 2.
resource "aws_instance" "ps-t2micro-2" {
    ami                          = data.aws_ami.ubuntu.id
    associate_public_ip_address  = true
    disable_api_termination      = false
    ebs_optimized                = false
    get_password_data            = false
    hibernation                  = false
    instance_type                = "t2.micro"
    ipv6_address_count           = 0
    ipv6_addresses               = []
    monitoring                   = false
    subnet_id                    = aws_subnet.lab_vpc_subnet_a.id
    vpc_security_group_ids       = [aws_security_group.ssh.id]
    user_data = data.template_file.action3.rendered
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
#creating EC2 instance resource 3.
resource "aws_instance" "ps-t2micro-3" {
    ami                          = data.aws_ami.ubuntu.id
    associate_public_ip_address  = true
    disable_api_termination      = false
    ebs_optimized                = false
    get_password_data            = false
    hibernation                  = false
    instance_type                = "t2.micro"
    ipv6_address_count           = 0
    ipv6_addresses               = []
    monitoring                   = false
    subnet_id                    = aws_subnet.lab_vpc_subnet_a.id
    vpc_security_group_ids       = [aws_security_group.ssh.id]
    user_data = data.template_file.action4.rendered
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
#creating EC2 instance resource 4.
resource "aws_instance" "ps-t2micro-4" {
    ami                          = data.aws_ami.ubuntu.id
    associate_public_ip_address  = true
    disable_api_termination      = false
    ebs_optimized                = false
    get_password_data            = false
    hibernation                  = false
    instance_type                = "t2.micro"
    ipv6_address_count           = 0
    ipv6_addresses               = []
    monitoring                   = false
    subnet_id                    = aws_subnet.lab_vpc_subnet_a.id
    vpc_security_group_ids       = [aws_security_group.ssh.id]
    user_data = data.template_file.action5.rendered
    tags = {
        Name = "DB-02"
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

#connect to different boxes and run commands to generate traffic (can even do on a timer)

data "template_file" "action1" {
  template = file("action1.sh")
  vars ={
      micro_1_ip = element(tolist(aws_network_interface.privates-1.private_ips), 0)
  }
}

data "template_file" "action2" {
  template = file("action2.sh")
  vars ={
      micro_0_ip = element(tolist(aws_network_interface.privates-0.private_ips), 0)
  }
}

#app server cpu load 
data "template_file" "action3" {
  template = file("action3.sh")
}

data "template_file" "action4" {
  template = file("action4.sh")
}

data "template_file" "action5" {
  template = file("action5.sh")
}
