// Send SNS Notifications
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

resource "aws_lambda_function" "sns_notifications" {
  filename      = "notifications.zip"
  function_name = "sns-notifications"
  description   = "Receives SNS Notifications"
  role          = aws_iam_role.iam_for_lambda.arn
  depends_on    = [aws_iam_role_policy_attachment.lambda_logs]
  handler       = "index.handler"

  source_code_hash = filebase64sha256("notifications.zip")

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
          "Description": "Send Notifications with AWS SNS Using the JavaScript SDK",
          "Repositories": [
            {
              "PathComponent": "app",
              "RepositoryUrl": "https://github.com/ps-interactive/aws-sns-js-sdk.git"
            }
          ]
        }
      }
    }
  }
  STACK
}
