provider "aws" {
  version = "~> 2.0"
  region = "us-west-2"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_ssm_parameter" "dev-app1-user" {
    name = "/dev/app1/credentials/username"
    description = "Username for development app1"
    type = "String"
    value = "devapp1user"
}

resource "aws_ssm_parameter" "dev-app1-pass" {
    name = "/dev/app1/credentials/password"
    description = "Password for development app1"
    type = "SecureString"
    value = "fixme"
}

resource "aws_ssm_parameter" "dev-db1-user" {
    name = "/dev/db1/credentials/username"
    description = "Username for development db1"
    type = "String"
    value = "devdb1user"
}

resource "aws_ssm_parameter" "dev-db1-pass" {
    name = "/dev/db1/credentials/password"
    description = "Password for development db1"
    type = "SecureString"
    value = "devdb1pass"
}

resource "aws_ssm_parameter" "prd-app1-user" {
    name = "/prd/app1/credentials/username"
    description = "Username for production app1"
    type = "String"
    value = "prdapp1user"
}

resource "aws_ssm_parameter" "prd-app1-pass" {
    name = "/prd/app1/credentials/password"
    description = "Password for production app1"
    type = "SecureString"
    value = "prdapp1pass"
}

resource "aws_ssm_parameter" "prd-db1-user" {
    name = "/prd/db1/credentials/username"
    description = "Username for production db1"
    type = "String"
    value = "prddb1user"
}

resource "aws_iam_role_policy" "dev_policy" {
    name = "dev-policy"
    role = aws_iam_role.dev_lambda_role.id
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParametersByPath"
            ],
            "Resource": "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "dev_lambda_role" {
    name = "dev_lambda_role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "prd_policy" {
    name = "prd-policy"
    role = aws_iam_role.prd_lambda_role.id
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParametersByPath"
            ],
            "Resource": "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "prd_lambda_role" {
    name = "prd_lambda_role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_lambda_function" "dev_lambda" {
    filename = "./initial_lambda.zip"
    function_name = "dev_lambda"
    role = aws_iam_role.dev_lambda_role.arn
    handler = "initial_lambda.handler"
    runtime = "python3.8"
}

resource "aws_lambda_function" "prd_lambda" {
    filename = "./final_lambda.zip"
    function_name = "prd_lambda"
    role = aws_iam_role.prd_lambda_role.arn
    handler = "final_lambda.handler"
    runtime = "python3.8"
}
