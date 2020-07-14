provider "aws" {
  region = "us-west-2"
    access_key = "AKIAYVVEZV4AHTPCDZUR"
    secret_key = "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"
}

data "aws_ami" "ami" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "instance_development_one" {
  ami                  = data.aws_ami.ami.image_id
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.main.name

  tags = {
    Environment = "Development"
  }
}

resource "aws_instance" "instance_development_two" {
  ami                  = data.aws_ami.ami.image_id
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.main.name

  tags = {
    Environment = "Development"
  }
}

resource "aws_instance" "instance_production_one" {
  ami                  = data.aws_ami.ami.image_id
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.main.name

  tags = {
    Environment = "Production"
  }
}

resource "aws_instance" "instance_production_two" {
  ami                  = data.aws_ami.ami.image_id
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.main.name

  tags = {
    Environment = "Production"
  }
}

resource "aws_iam_instance_profile" "main" { role = aws_iam_role.main.name }

resource "aws_iam_role" "main" { assume_role_policy = data.aws_iam_policy_document.assume.json }

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.main.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.logs.arn
}

resource "aws_iam_policy" "logs" { policy = data.aws_iam_policy_document.logs.json }

data "aws_iam_policy_document" "logs" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.logs.arn}/*"]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }
}

resource "random_string" "logs" {
  length  = 16
  special = false
  upper   = false
}

resource "aws_s3_bucket" "logs" {
  bucket = "run-command-logs-${random_string.logs.result}"
}

data "aws_vpc" "default" { default = true }
data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id

  filter {
    name   = "group-name"
    values = ["default"]
  }
}

resource "aws_security_group_rule" "http" {
  security_group_id = data.aws_security_group.default.id
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  from_port         = 80
  to_port           = 80
}
