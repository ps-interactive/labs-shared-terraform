provider "aws" {
    version = "~> 2.0"
    region = "us-west-2"
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
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

# TODO remove before release
resource "aws_key_pair" "pluralsight" {
    key_name = "pluralsight"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCp1E2D1EwnRx5L20OeZZcWaSQxfsGykmHwRIJFTq0fkb4M4rZkeFDXjR3ebqwa+E7w+A0WhkpIV4B0Qe3y+qlzO/9+A8pQzzCFkaPheQrQFEqciI7mZ75UIEsNF+PynjM2RTIXNPeDndMJIpwZxgIp0Q4IipTpFRSlPgR9+UJwnOhSFc06aBiRASjadCTdAA+tAGQBOBDpdo1rCThrhNVvVNUwX/TE+nRb4skcV2eLhlIUraErRBJIHlgiyAdg3p6Y0CF83DJVYAz4S8q8jWXIR+6IJw6xXNH48A/q8zp2JeOCwOvMZTfiyPTNXdKVyNhhRpm9pJlrWLudHUB/52X+/SBfTJBr4LfSH+75bbyoNNR+Ui5YF9SJG28OQQ0eKUquqy/bY8zwPsxTd7Zl4+vsFMHt7DBQ3XQePaXll+Gbc57jEzbHZpwHbyIVJ17ldn7jRVW40FkxkoEYbY3Fx3O41Ui3sgXVUmlkFv6lOEg9wj6Aa8o0F2ijry2UOdMBBgJv1kAms+mDlWlrkVe3idQqxhwzujRkb/3iMgli1o1rf1OjH3sPv/5grvVZzzl9NS3Z4HKUtdP+8NSKrZHH3atm7N++MVPzOYMWCpceDJ3cQDr5Zu32SQHnEMBrKsYWyL725LeUHTh9NaCbENr1wrlCrOoA8MkrugAzSAc4SoUjBw== user@dev"
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

resource "aws_instance" "pluralsight" {
    count = 1
    ami = data.aws_ami.latest-ubuntu.id
    instance_type = "t3a.small"
    subnet_id = sort(data.aws_subnet_ids.default.ids)[count.index]
    key_name = aws_key_pair.pluralsight.key_name
    vpc_security_group_ids = [aws_security_group.pluralsight.id]
    user_data = data.cloudinit_config.config.rendered

    tags = {
        Name = "pluralsight-app"
    }
}

output pluralsight-ec2-public-ips {
    value = aws_instance.pluralsight.*.public_ip
}

data "local_file" "server" {
    filename = "${path.module}/server.py"
}

data "cloudinit_config" "config" {
    gzip = true
    base64_encode = true

    part {
        content_type = "text/x-shellscript"
        content = data.local_file.server.content
    }
}
