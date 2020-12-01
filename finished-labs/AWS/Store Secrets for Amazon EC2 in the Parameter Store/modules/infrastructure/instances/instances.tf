/*
This template is for provisioning of
  any resource that uses instances such as
  EC2 and RDS
*/

# No inbound rules because this is meant to be access via
# session manager
resource "aws_security_group" "bastion" {
  name        = "${local.name_tag_prefix}-Bastion-Sg"
  description = "Security group for bastion host"
  vpc_id      = var.vpc

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow to anywhere from this bastion"
  }

  tags = {
    Name    = "${local.name_tag_prefix}-Bastion-Sg"
    Env     = var.environment
    Project = var.project_name
  }
}

resource "aws_security_group" "db" {
  name        = "${local.name_tag_prefix}-Db-Sg"
  description = "Security group for db instance"
  vpc_id      = var.vpc

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = 6
    security_groups = [aws_security_group.bastion.id]
    description     = "Allow from bastion to this db"
  }
  egress = []

  tags = {
    Name    = "${local.name_tag_prefix}-Db-Sg"
    Env     = var.environment
    Project = var.project_name
  }
}

resource "aws_iam_role" "ssm_role" {
  name_prefix = "${var.project_name}${var.environment}"
  path        = "/${var.project_name}/${var.environment}/"

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

  tags = {
    Env     = var.environment
    Project = var.project_name
  }
}

resource "aws_iam_role_policy" "ssm_policy" {
  name_prefix = "${var.project_name}${var.environment}"
  role        = aws_iam_role.ssm_role.id
  policy      = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:UpdateInstanceInformation",
                "ssm:GetParameters",
                "ssm:GetParameter",
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetEncryptionConfiguration"
            ],
            "Resource": "*"
        }
    ]
}
  EOF
}

resource "aws_iam_role" "cloudformation_role" {
  name_prefix = "${var.project_name}${var.environment}"
  path        = "/${var.project_name}/${var.environment}/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "servicecatalog.amazonaws.com",
          "servicecatalog.ap-southeast-1.amazonaws.com",
          "cloudformation.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    Env     = var.environment
    Project = var.project_name
  }
}

resource "aws_iam_role_policy" "cloudformation_policy" {
  name_prefix = "${var.project_name}${var.environment}"
  role        = aws_iam_role.cloudformation_role.id
  policy      = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
  EOF
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name_prefix = "${var.project_name}${var.environment}"
  path        = "/${var.project_name}/${var.environment}/"
  role        = aws_iam_role.ssm_role.name
}

resource "aws_instance" "bastion" {
  ami                  = data.aws_ssm_parameter.amazon_linux_ami.value
  subnet_id            = var.private_subnets[0]
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name
  security_groups      = [aws_security_group.bastion.id]
  user_data            = <<-EOF
    #!/bin/bash
    amazon-linux-extras install postgresql11 vim epel -y
    yum install -y postgresql-server postgresql-devel
    EOF
  tags = {
    Name    = "${local.name_tag_prefix}-BastionInstance"
    Env     = var.environment
    Project = var.project_name
  }
} 

