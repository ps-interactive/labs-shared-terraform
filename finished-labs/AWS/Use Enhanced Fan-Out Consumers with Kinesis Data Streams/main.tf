variable "region" {
  default = "us-west-2"
}

provider "aws" {
  version = "~> 2.6"
  region  = var.region
  profile="ps"
}

resource "aws_cloudwatch_event_rule" "invoker" {
  name        = "click-stream-invoker"
  description = "CW Rule to invoke Lambda function every minute"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.invoker.name
  target_id = "InvokeLambda"
  arn       = aws_lambda_function.lambda.arn
}

resource "aws_lambda_permission" "lambda_event_permission" {
  statement_id  = "AllowExecutionFromCWRule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.invoker.arn
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
resource "aws_iam_policy" "lambda_logging_kinesis" {
  name        = "lambda_logging_kinesis"
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
    },
            {
            "Sid": "KinesisPutRecords",
            "Effect": "Allow",
            "Action": [
                "kinesis:PutRecord",
                "kinesis:PutRecords"
            ],
            "Resource": "*"
        }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging_kinesis.arn
}

resource "aws_lambda_function" "lambda" {
    filename        = "producer_function.zip"
    function_name   = "producer_function"
    handler         = "index.lambda_handler"
    role            = aws_iam_role.iam_for_lambda.arn
    runtime         = "python3.7"
}

# Cloud 9 Development environment
resource "aws_cloud9_environment_ec2" "development" {
  name                        = "kinesis-dev"
  instance_type               = "t3.small"
}
