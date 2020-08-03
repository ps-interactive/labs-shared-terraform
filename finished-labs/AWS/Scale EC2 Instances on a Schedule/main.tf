provider "aws" {
    alias = "us-west-2"
    region = "us-west-2"
}

provider "aws" {
    alias = "route53"
    region = "us-west-2"
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
}

data "aws_security_group" "default" {
    vpc_id = data.aws_vpc.default.id
    filter {
        name = "group-name"
        values = ["default"]
    }
}

data "aws_ami" "latest-amazonlinux2" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    filter {
        name = "root-device-type"
        values = ["ebs"]
    }
}

data "aws_ip_ranges" "ec2-connect-usw2" {
    regions = ["us-west-2"]
    services = ["ec2_instance_connect"]
}

output "amazonlinux2-ami" {
    value = data.aws_ami.latest-amazonlinux2.id
}
