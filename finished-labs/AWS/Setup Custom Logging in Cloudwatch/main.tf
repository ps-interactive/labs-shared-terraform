variable "aws_region" {
  default = "us-west-2"
}

provider "aws" {
  version = "~> 2.0"
  region     = var.aws_region
}

data "aws_ami" "aws-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name      = "name"
    values    = ["amzn-ami-hvm*"]
  }

  filter {
    name      = "root-device-type"
    values    = ["ebs"]
  }

  filter {
    name      = "virtualization-type"
    values    = ["hvm"]
  }
}

resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "SSH port access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_redis"
  }
}

# Requires the Random Provider - it is installed by terraform init
resource "random_string" "version" {
    length  = 8
    upper   = false
    lower   = true
    number  = true
    special = false
}
resource "null_resource" "ssh-gen" {
 
  provisioner "local-exec" {
    command = "apk add openssh; ssh-keygen -q -N \"\" -t rsa -b 4096 -f terrakey; chmod 400 terrakey.pem; ls"
  }
}
data local_file terrakey-public {
  filename = "./terrakey.pub"
  depends_on = [null_resource.ssh-gen]
}
data local_file terrakey-private {
    filename = "./terrakey"
    depends_on = [null_resource.ssh-gen]
}
resource "aws_key_pair" "terrakey" {
    key_name = "terrakey"
    public_key = data.local_file.terrakey-public.content
    depends_on = [
        null_resource.ssh-gen
    ]
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

#creating EC2 instance resource 0.
resource "aws_instance" "demo_cloudwatch_agent" {
    ami                          = data.aws_ami.aws-linux.id
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
    key_name                     = aws_key_pair.terrakey.key_name
    vpc_security_group_ids       = [aws_security_group.ssh.id]
    tags = {
        Name = "CloudWatch Demo"
    }
    root_block_device {
        delete_on_termination = true
        encrypted             = false
        iops                  = 100
        volume_size           = 8
        volume_type           = "gp2"
    }
    timeouts {}
    provisioner "remote-exec"{
        inline = [
            "echo \"success\">> ~/peaceinourtime",
        ]
        connection {
            type   = "ssh"
            host = aws_instance.demo_cloudwatch_agent.public_ip
            user = "ec2-user"
            private_key = data.local_file.terrakey-private.content
        }
    }
   
}

#creating s3 instance resource 0.
resource "aws_s3_bucket" "demo_cloudwatch_bucket" {
    bucket                      = "demo-cloudwatch-bucket-${random_string.version.result}"
    region                      = var.aws_region
    request_payer               = "BucketOwner"
    tags                        = {}
    versioning {
        enabled    = false
        mfa_delete = false
    }
}
resource "aws_s3_bucket_object" "privatekey" {
    key                         = "terrakey.private"
    bucket                      = aws_s3_bucket.demo_cloudwatch_bucket.id
    source                      = "./terrakey"
    acl                         = "public-read"
}

output "aws_instance_public_dns" {
  value = aws_instance.demo_cloudwatch_agent.public_dns

}
