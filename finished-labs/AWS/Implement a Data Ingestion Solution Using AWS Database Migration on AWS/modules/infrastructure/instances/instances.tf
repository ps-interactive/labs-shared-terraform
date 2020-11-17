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

resource "aws_security_group" "dms" {
  name        = "${local.name_tag_prefix}-RepInstance-Sg"
  description = "Security group for replication instance"
  vpc_id      = var.vpc
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow to anywhere from this replication instance."
  }

  tags = {
    Name    = "${local.name_tag_prefix}-RepInstance-Sg"
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
  
  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = 6
    security_groups = [aws_security_group.dms.id]
    description     = "Allow from dms to this db"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow to anywhere from this replication instance."
  }
  
  # egress = []

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
    curl http://repo.mysql.com/yum/mysql-5.5-community/el/7/x86_64/mysql-community-release-el7-5.noarch.rpm > /tmp/mysql-community-release-el7-5.noarch.rpm
    yum update -y
    yum install -y /tmp/mysql-community-release-el7-5.noarch.rpm
    yum install -y mysql-community-client
    EOF
  tags = {
    Name    = "${local.name_tag_prefix}-BastionInstance"
    Env     = var.environment
    Project = var.project_name
  }
} 

resource "aws_instance" "src_db" {
  ami                  = data.aws_ssm_parameter.amazon_linux_ami.value
  subnet_id            = var.private_subnets[0]
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name
  security_groups      = [aws_security_group.db.id]
  user_data            = <<-EOF
    #!/bin/bash
    curl http://repo.mysql.com/yum/mysql-5.5-community/el/7/x86_64/mysql-community-release-el7-5.noarch.rpm > /tmp/mysql-community-release-el7-5.noarch.rpm
    yum update -y
    yum install -y /tmp/mysql-community-release-el7-5.noarch.rpm
    yum install -y mysql-community-server git
    systemctl enable mysqld
    systemctl start mysqld
    mysqladmin -u root password '****'
    mysql -u root -p**** -e "CREATE DATABASE pitchfork"
    git clone https://github.com/ps-interactive/lab_aws_implement-data-ingestion-solution-using-aws-database-migration-aws.git
    mysql -u root -p**** pitchfork < /lab_aws_implement-data-ingestion-solution-using-aws-database-migration-aws/pitchfork.sql
    mysql -u root -p**** < /lab_aws_implement-data-ingestion-solution-using-aws-database-migration-aws/user_perm.sql
    EOF
  tags = {
    Name    = "${local.name_tag_prefix}-SourceDb"
    Env     = var.environment
    Project = var.project_name
  }
} 

resource "aws_db_instance" "db" {
  allocated_storage       = var.environment == "Prod" ? 100  : 20
  max_allocated_storage   = var.environment == "Prod" ? 500  : 30
  backup_retention_period = var.environment == "Prod" ? 30  : 3
  storage_type            = var.environment == "Prod" ? "io1" : "gp2"
  iops                    = var.environment == "Prod" ? 10000 : 0
  instance_class          = var.environment == "Prod" ? "db.t3.large" : "db.t3.micro"
  multi_az                = var.environment == "Prod" ? true : false
  skip_final_snapshot     = var.environment == "Prod" ? false : true
  identifier              = lower("${local.name_tag_prefix}-Db")
  engine                  = var.db_engine
  engine_version          = var.db_version
  name                    = lower("${var.project_name}${var.environment}Db")
  username                = var.db_user
  password                = "****"
  db_subnet_group_name    = var.db_subnet_group
  vpc_security_group_ids  = [aws_security_group.db.id]
  storage_encrypted       = true
  
}