// Kinesis JS
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

resource "aws_lambda_function" "kinesis_consumer" {
  filename      = "consumer.zip"
  function_name = "kinesis-consumer"
  description   = "Reads from Kinesis Data Stream and writes to DynamoDB"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"

  source_code_hash = filebase64sha256("consumer.zip")

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
          "InstanceType": "t2.nano",
          "Name": "PS Labs Code ${random_string.stack_id.result}",
          "Description": "Kinesis and JS",
          "Repositories": [
            {
              "PathComponent": "app",
              "RepositoryUrl": "https://github.com/ps-interactive/kinesis-lambda-js"
            }
          ]
        }
      }
    }
  }
  STACK
}

resource "aws_dynamodb_table" "toll_records" {
  name = "toll-records"
  read_capacity  = 5
  write_capacity = 25
  hash_key       = "licensePlate"
  range_key      = "timeStamp"

  attribute {
    name = "licensePlate"
    type = "S"
  }
  attribute {
    name = "timeStamp"
    type = "N"
  }
}
