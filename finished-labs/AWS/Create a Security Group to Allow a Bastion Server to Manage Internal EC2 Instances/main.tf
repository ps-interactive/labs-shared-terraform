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
    filter {
        name = "group-name"
        values = ["default"]
    }
}

data "aws_ami" "latest-ubuntu" {
    most_recent = true
    owners = ["099720109477"]

    filter {
        name   = "name"
        values = ["ubuntu/images/*ubuntu-bionic-18.04-amd64-server-*"]
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
resource "aws_instance" "pluralsight" {
    count = 1
    ami = data.aws_ami.latest-ubuntu.id
    instance_type = "t3a.small"
    subnet_id = sort(data.aws_subnet_ids.default.ids)[count.index]
    user_data = data.cloudinit_config.config.rendered
    vpc_security_group_ids = [data.aws_security_group.default.id]
    associate_public_ip_address = false

    tags = {
        Name = "pluralsight-internal"
    }
}

output pluralsight-ec2-private-ips {
    value = aws_instance.pluralsight.*.private_ip
}

data "cloudinit_config" "config" {
    gzip = true
    base64_encode = true

    part {
        content_type = "text/x-shellscript"
        content = <<-EOF
          #!/bin/bash
          sed -i 's/PasswordAuthentication\ no/PasswordAuthentication\ yes/' /etc/ssh/sshd_config
          service sshd restart
          echo 'ubuntu:pluralsight123' | chpasswd
        EOF
    }
}
