resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_cloudwatch_log_group" "flow_logs_group" {
  name = "FlowLogs"
}

resource "aws_flow_log" "accept" {
  iam_role_arn    = aws_iam_role.vpc_flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.flow_logs_group.arn
  traffic_type    = "ACCEPT"
  vpc_id          = aws_default_vpc.default.id
}

resource "aws_flow_log" "reject" {
  iam_role_arn    = aws_iam_role.vpc_flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.flow_logs_group.arn
  traffic_type    = "REJECT"
  vpc_id          = aws_default_vpc.default.id
}

resource "aws_iam_role" "vpc_flow_log_role" {
  name = "vpc_flow_log_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "vpc_flow_log_role_policy" {
  name = "vpc_flow_log_role_policy"
  role = aws_iam_role.vpc_flow_log_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

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
  name = "host_security_group"

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

data "template_file" "user_data" {
  template = file("src/user_data.tpl")
}

resource "aws_instance" "host" {
  ami = data.aws_ami.amazon_linux_v2.id
  iam_instance_profile = aws_iam_instance_profile.host_profile.name
  instance_type = var.instance_type
  count = length(var.availability_zones)
  availability_zone = var.availability_zones[count.index]
  user_data = data.template_file.user_data.rendered
  key_name = "keypair"
  vpc_security_group_ids = [aws_security_group.lab_user_access.id]

  tags = {
    Name = "${var.ec2_name}-${count.index}"
  }
}

resource "aws_iam_instance_profile" "host_profile" {
  name = "host-profile"
  role = aws_iam_role.host_role.name
}

resource "aws_iam_role" "host_role" {
  name = "host-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "host_role_attach" {
  role = aws_iam_role.host_role.name
  policy_arn = aws_iam_policy.host_role_policy.arn
}

resource "aws_iam_policy"  "host_role_policy" {
  name        = "host_role_policy"
  path        = "/"
  description = "host_role_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
