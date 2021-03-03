resource "aws_key_pair" "keypair" {
  key_name = "keypair"
  public_key = file("src/keypair.pub")
}

data "aws_ami" "amazon_linux_v2" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-2*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Amazon

}

resource "aws_security_group" "lab_user_access" {
  name = "marketing-web-server"

  ingress {
    description = "SSH from the world"
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    self = true
  }

  ingress {
    description = "HTTP from the world"
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    self = true
  }

  egress {
    description = "Unrestricted"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "web" {
  ami = data.aws_ami.amazon_linux_v2.id
  instance_type = var.instance_type
  count = length(var.availability_zones)
  availability_zone = var.availability_zones[count.index]
  user_data = data.template_file.user_data.rendered
  key_name = "keypair"
  vpc_security_group_ids = [aws_security_group.lab_user_access.id]

  tags = {
    Name = var.ec2_name
  }
}

data "template_file" "user_data" {
  template = file("src/user_data.tpl")
}