variable "region" {
  default = "us-west-2"
}

provider "aws" {
  version = "~> 2.6"
  region  = var.region
  profile = "ps"
}

# Variable used in the creation of the `lab_vpc_internet_access` resource
variable "cidr_block" {
  default = "0.0.0.0/0"
}

# Custom VPC shows the use of tags to name resources
# Instance Tenancy set to `default` is not to be confused with the concept of a Default VPC
resource "aws_vpc" "lab_vpc" {
  cidr_block       = "10.0.0.0/26"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "Lab VPC"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.lab_vpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Custom Internet Gateway - not created as part of the initialization of a VPC
resource "aws_internet_gateway" "lab_vpc_gateway" {
  vpc_id = aws_vpc.lab_vpc.id
}

# Create a Route in the Main Routing Table - no need to create a Custom Routing Table
# Use `main_route_table_id` to pull the ID of the main routing table
resource "aws_route" "lab_vpc_internet_access" {
  route_table_id         = aws_vpc.lab_vpc.main_route_table_id
  destination_cidr_block = var.cidr_block
  gateway_id             = aws_internet_gateway.lab_vpc_gateway.id
}

# Create Private Route Table
resource "aws_route_table" "prv_route_table" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "Private Route Table"
  }
}

# Add a subnet to the VPC
resource "aws_subnet" "lab_vpc_subnet_pub_a" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.0.0/28"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
  tags = {
    Name = "Sub-Public-a"
  }
}

# Optional Subnets - make sure that the `cidr_block`s do not conflict
resource "aws_subnet" "lab_vpc_subnet_pub_b" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.0.16/28"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2b"
  tags = {
    Name = "Sub-Public-b"
  }
}

resource "aws_subnet" "lab_vpc_subnet_prv_a" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.0.32/28"
  map_public_ip_on_launch = false
  availability_zone       = "us-west-2a"
  tags = {
    Name = "Sub-Private-a"
  }
}

resource "aws_subnet" "lab_vpc_subnet_prv_b" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.0.48/28"
  map_public_ip_on_launch = false
  availability_zone       = "us-west-2b"
  tags = {
    Name = "Sub-Private-b"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.lab_vpc_subnet_prv_a.id
  route_table_id = aws_route_table.prv_route_table.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.lab_vpc_subnet_prv_b.id
  route_table_id = aws_route_table.prv_route_table.id
}

resource "aws_security_group" "_" {
  name = "ps-rds-sg"

  description = "RDS (terraform-managed)"
  vpc_id      = aws_vpc.lab_vpc.id

  # Only MySQL in
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups=[aws_default_security_group.default.id]
    
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "_" {
  name       = "db subnet group for "
  subnet_ids = [aws_subnet.lab_vpc_subnet_prv_a.id, aws_subnet.lab_vpc_subnet_prv_b.id]
}

resource "aws_db_instance" "lab_rds" {
  identifier          = "lab-db-instance"
  instance_class      = "db.t2.micro"
  allocated_storage   = 10
  engine              = "mysql"
  engine_version      = "8.0.20"
  name                = "labdb"
  username            = "labuser"
  password            = "LabPass20"
  skip_final_snapshot = true
  db_subnet_group_name    = aws_db_subnet_group._.id
  vpc_security_group_ids = [aws_security_group._.id]
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_lambda_function" "lambda" {
    filename        = "rds-function.zip"
    function_name   = "rds-function"
    handler         = "index.handler"
    role            = aws_iam_role.iam_for_lambda.arn
    runtime         = "nodejs12.x"

    environment {
      variables = {
        RDS_ENDPOINT = "${aws_db_instance.lab_rds.endpoint}"
      }
  }
}