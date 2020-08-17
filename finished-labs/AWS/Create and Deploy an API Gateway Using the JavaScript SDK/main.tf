// API Gateway with JS SDK
variable "region" {
  default = "us-west-2"
}

provider "aws" {
  version = "~> 2.0"
  region  = var.region
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

resource "aws_lambda_function" "hello_world_lambda" {
  filename      = "users.zip"
  function_name = "list-users"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"

  source_code_hash = filebase64sha256("users.zip")

  runtime = "nodejs12.x"
}

resource "random_string" "stack_id" {
  length  = 8
  special = false
}

resource "aws_cloudformation_stack" "lab_ide_stack" {
  name          = "lab-ide-stack-${random_string.stack_id.result}"
  template_body = <<STACK
  {
    "Resources": {
      "LabIDE": {
        "Type": "AWS::Cloud9::EnvironmentEC2",
        "Properties": {
          "InstanceType": "t3.small",
          "Name": "PS Labs Code ${random_string.stack_id.result}",
          "Description": "API Gateway and JS SDK",
          "Repositories": [
            {
              "PathComponent": "app",
              "RepositoryUrl": "https://github.com/ps-interactive/api-gateway-js"
            }
          ]
        }
      }
    }
  }
  STACK
}
