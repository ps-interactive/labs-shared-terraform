variable "region" {
  default = "us-west-2"
}

provider "aws" {
  version = "~> 2.6"
  region  = var.region
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "lambda-comprehend-ddb-role"

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

resource "aws_iam_policy" "lambda_comprehend_policy" {
  name        = "lambda-comprehend-ddb"
  path        = "/"
  description = "IAM policy for Amazon Comprehend, DynamoDB and Lambda logging"

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
            "Effect": "Allow",
            "Action": [
                "comprehend:*"
            ],
            "Resource": "*"
        },
                {
            "Effect": "Allow",
            "Action": [
                "dynamodb:*"
            ],
            "Resource": "*"
        }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_comprehend_policy.arn
}

resource "aws_dynamodb_table" "sentiment_table" {
  name           = "sentiment_table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "review_id"

  attribute {
    name = "review_id"
    type = "S"
  }
}

resource "aws_lambda_function" "lambda" {
    filename        = "get-sentiment.zip"
    function_name   = "get-sentiment"
    handler         = "index.lambda_handler"
    role            = aws_iam_role.iam_for_lambda.arn
    runtime         = "python3.7"
    description     = "Carved Rock Fitness Lambda function that determines the sentiment of a given product review text and inserts the record into the DynamoDB table"
}

