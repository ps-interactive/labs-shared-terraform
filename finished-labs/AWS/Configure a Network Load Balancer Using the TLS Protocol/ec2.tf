# ec2.tf

data "aws_ami" "amazon_linux_v2" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "first_tier" {
  for_each               = var.subnets
  ami                    = data.aws_ami.amazon_linux_v2.id
  instance_type          = var.instance_type
  availability_zone      = each.key
  subnet_id              = aws_subnet.subnets[each.key].id

  tags = {
    Name = var.first_tier_name
  }
}

resource "aws_instance" "second_tier" {
  for_each               = var.subnets
  ami                    = data.aws_ami.amazon_linux_v2.id
  instance_type          = var.instance_type
  availability_zone      = each.key
  subnet_id              = aws_subnet.subnets[each.key].id

  tags = {
    Name = var.second_tier_name
  }
}
