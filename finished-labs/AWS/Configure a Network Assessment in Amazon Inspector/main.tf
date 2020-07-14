provider "aws" { region = "us-west-2" }

data "aws_ami" "amazon_linux_2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_ami" "ubuntu" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu-minimal/images/hvm-ssd/ubuntu-focal-20.04-amd64-minimal-*"]
  }
}

data "aws_vpc" "default" { default = true }
data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id

  filter {
    name   = "group-name"
    values = ["default"]
  }
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "template_cloudinit_config" "http_server" {
  part {
    content_type = "text/cloud-config"
    content      = <<-EOF
      package_update: true
      package_upgrade: true
      packages:
        - httpd
      write_files:
        - path: /var/www/html/index.html
          content: |
            <!DOCTYPE html>
            <html>
              <head>
                <title>EC2 HTTPd Server</title>
                <meta charset="utf-8" />
              </head>
              <body>
                <h1>EC2 HTTPd Server</h1>
              </body>
            </html>
      runcmd:
        - systemctl enable --now httpd
        - curl https://inspector-agent.amazonaws.com/linux/latest/install | sudo bash
    EOF
  }
}

data "template_cloudinit_config" "port_listener" {
  part {
    content_type = "text/cloud-config"
    content      = <<-EOF
      package_update: true
      package_upgrade: true
      packages:
        - nc
      runcmd:
        - curl https://inspector-agent.amazonaws.com/linux/latest/install | sudo bash
        - yes test | nc -kl 25565
    EOF
  }
}

resource "aws_security_group" "ssh" {
  ingress {
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
}

resource "aws_security_group" "http" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "port_listener" {
  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "postgresql" {
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "instance1" {
  ami                    = data.aws_ami.amazon_linux_2.image_id
  instance_type          = "t3.micro"
  user_data_base64       = data.template_cloudinit_config.http_server.rendered
  vpc_security_group_ids = [aws_security_group.http.id]
  tags = {
    Environment = "Development"
  }
}

resource "aws_instance" "instance2" {
  ami                    = data.aws_ami.amazon_linux_2.image_id
  instance_type          = "t3.micro"
  user_data_base64       = data.template_cloudinit_config.http_server.rendered
  vpc_security_group_ids = [aws_security_group.http.id]
  tags = {
    Environment = "Production"
  }
}

resource "aws_instance" "instance3" {
  ami              = data.aws_ami.amazon_linux_2.image_id
  instance_type    = "t3.micro"
  user_data_base64 = data.template_cloudinit_config.port_listener.rendered
  vpc_security_group_ids = [
    aws_security_group.port_listener.id,
    aws_security_group.ssh.id,
  ]
  tags = {
    Environment = "Production"
  }
}

resource "aws_instance" "instance4" {
  ami                    = data.aws_ami.ubuntu.image_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.postgresql.id]
  tags = {
    Environment = "Production"
  }
}
