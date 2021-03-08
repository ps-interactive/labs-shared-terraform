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
  name = "WebServers"

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


resource "aws_autoscaling_group" "web_servers" {
  name                 = "MyASG"
  launch_template {
    id      = aws_launch_template.web_server.id
  }
  min_size             = 2
  max_size             = 2
  availability_zones = var.availability_zones
  health_check_grace_period = 5

  tag {
    key                 = "Name"
    value               = "ASG-WebServer"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "user_data" {
  template = file("src/user_data.tpl")
}