provider "aws" {
    version = "~> 2.0"
    region  = "us-west-2"
}

resource "random_string" "version" {
    length  = 8
    upper   = false
    lower   = true
    number  = true
    special = false
}

resource "tls_private_key" "pki" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "pki" {
  content         = tls_private_key.pki.private_key_pem
  filename        = "./terrakey"
  file_permission = "0600"
}

resource "aws_key_pair" "terrakey" {
    key_name = "terrakey"
    public_key = tls_private_key.pki.public_key_openssh
}

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
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_internet_gateway" "lab_vpc_gateway" {
  vpc_id = aws_vpc.lab_vpc.id
}

resource "aws_route" "lab_vpc_internet_access" {
  route_table_id         = aws_vpc.lab_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.lab_vpc_gateway.id
}

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

resource "aws_instance" "ps-t2micro-0" {
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
    key_name                     = aws_key_pair.terrakey.key_name
    vpc_security_group_ids       = [aws_security_group.ssh.id]
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

resource "aws_instance" "ps-t2micro-1" {
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
    key_name                     = aws_key_pair.terrakey.key_name
    vpc_security_group_ids       = [aws_security_group.ssh.id]
    tags = {
        Name = "Web-02"
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
    key_name                     = aws_key_pair.terrakey.key_name
    vpc_security_group_ids       = [aws_security_group.ssh.id]
    tags = { Name = "App-01" }
    root_block_device {
        delete_on_termination = true
        encrypted             = false
        iops                  = 100
        volume_size           = 8
        volume_type           = "gp2"
    }
    timeouts {}

}

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
    key_name                     = aws_key_pair.terrakey.key_name
    vpc_security_group_ids       = [aws_security_group.ssh.id]
    tags = { Name = "DB-01" }
    root_block_device {
        delete_on_termination = true
        encrypted             = false
        iops                  = 100
        volume_size           = 8
        volume_type           = "gp2"
    }
    timeouts {}
}

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
    key_name                     = aws_key_pair.terrakey.key_name
    vpc_security_group_ids       = [aws_security_group.ssh.id]
    tags = { Name = "DB-02" }
    root_block_device {
        delete_on_termination = true
        encrypted             = false
        iops                  = 100
        volume_size           = 8
        volume_type           = "gp2"
    }
    timeouts {}
}

resource "aws_s3_bucket" "ps-s3-0" {
    bucket                      = "ps-s3-0-${random_string.version.result}"
    region                      = "us-west-2"
    request_payer               = "BucketOwner"
    tags                        = {}
    versioning {
        enabled    = false
        mfa_delete = false
    }
}

resource "aws_s3_bucket_object" "privatekey" {
    key                         = "terrakey.private"
    bucket                      = aws_s3_bucket.ps-s3-0.id
    source                      = "./terrakey"
    acl                         = "public-read"
}

resource "null_resource" "action1" {
    triggers = {
        public_ip = aws_instance.ps-t2micro-0.public_ip
    }

    provisioner "remote-exec"{
        inline = [
            "echo \"success1\">> ~/peaceinourtime",
            "echo \"${aws_instance.ps-t2micro-1.public_ip}\">> ~/peaceinourtime2",
            "sudo sed '$a*/1 * * * * root nc ${aws_instance.ps-t2micro-1.public_ip} 22 -w 60' /etc/crontab | tee /tmp/cron.tab",
            "sudo mv /tmp/cron.tab /etc/crontab",
            "sudo chown root:root /etc/crontab",
            "sudo chmod 600 /etc/crontab",
            "sudo systemctl restart cron"
        ]
        connection {
            type   = "ssh"
            host = aws_instance.ps-t2micro-0.public_ip
            user = "ubuntu"
            private_key = data.local_file.pki.content
        }
    }
}

resource "null_resource" "action2" {
    triggers = {
        public_ip = aws_instance.ps-t2micro-1.public_ip
    }

    provisioner "remote-exec"{
        inline = [
            "echo \"success1\">> ~/peaceinourtime",
            "echo \"${aws_instance.ps-t2micro-0.public_ip}\">> ~/peaceinourtime2",
            "sudo sed '$a*/1 * * * * root nc ${aws_instance.ps-t2micro-0.public_ip} 22 -w 60' /etc/crontab | tee /tmp/cron.tab",
            "sudo mv /tmp/cron.tab /etc/crontab",
            "sudo chown root:root /etc/crontab",
            "sudo chmod 600 /etc/crontab",
            "sudo systemctl restart cron"
        ]
        connection {
            type   = "ssh"
            host = aws_instance.ps-t2micro-1.public_ip
            user = "ubuntu"
            private_key = data.local_file.pki.content
        }
    }
}

resource "null_resource" "action3" {
    triggers = {
        public_ip = aws_instance.ps-t2micro-2.public_ip
    }

    provisioner "remote-exec"{
        inline = [
            "echo \"success1\">> ~/peaceinourtime",
            "sudo apt update",
            "sudo apt -y install stress",
            "sudo sed '$a*/1 * * * * root stress -t 60 --cpu 4' /etc/crontab | tee /tmp/cron.tab",
            "sudo mv /tmp/cron.tab /etc/crontab",
            "sudo chown root:root /etc/crontab",
            "sudo chmod 600 /etc/crontab",
            "sudo systemctl restart cron"
        ]
        connection {
            type   = "ssh"
            host = aws_instance.ps-t2micro-2.public_ip
            user = "ubuntu"
            private_key = data.local_file.pki.content
        }
    }
}

resource "null_resource" "action4" {
    triggers = {
        public_ip = aws_instance.ps-t2micro-3.public_ip
    }

    provisioner "remote-exec"{
        inline = [
            "echo \"success1\">> ~/peaceinourtime",
            "sudo apt update",
            "sudo apt -y install stress",
            "sudo sed '$a*/1 * * * * root stress -t 60 -d 8 --hdd-bytes 300B' /etc/crontab | tee /tmp/cron.tab",
            "sudo sed '$a*/5 * * * * root stress -t 120 -d 20 --hdd-bytes 3000B' /tmp/cron.tab | tee /tmp/cron.tab2",
            "sudo mv /tmp/cron.tab2 /etc/crontab",
            "sudo chown root:root /etc/crontab",
            "sudo chmod 600 /etc/crontab",
            "sudo systemctl restart cron"

        ]
        connection {
            type   = "ssh"
            host = aws_instance.ps-t2micro-3.public_ip
            user = "ubuntu"
            private_key = data.local_file.pki.content
        }
    }
}

resource "null_resource" "action5" {
    triggers = {
        public_ip = aws_instance.ps-t2micro-4.public_ip
    }

    provisioner "remote-exec"{
        inline = [
            "echo \"success1\">> ~/peaceinourtime",
            "sudo apt update",
            "sudo apt -y install stress",
            "sudo sed '$a*/1 * * * * root stress -t 60 -d 2 --hdd-bytes 300B' /etc/crontab | tee /tmp/cron.tab",
            "sudo mv /tmp/cron.tab /etc/crontab",
            "sudo chown root:root /etc/crontab",
            "sudo chmod 600 /etc/crontab",
            "sudo systemctl restart cron",
        ]
        connection {
            type   = "ssh"
            host = aws_instance.ps-t2micro-4.public_ip
            user = "ubuntu"
            private_key = data.local_file.pki.content
        }
    }
}
