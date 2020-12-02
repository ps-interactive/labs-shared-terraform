data "aws_iam_policy_document" "AWSLambdaTrustPolicy" {
  statement {
    actions    = ["sts:AssumeRole"]
    effect     = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_dynamodb_table" "orders_table" {
  name           = "orders_table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "orderId"

  attribute {
    name = "orderId"
    type = "S"
  }
}

resource "aws_iam_role" "iam_for_createorder" {
  name               = "iam_for_createorder"
  assume_role_policy = data.aws_iam_policy_document.AWSLambdaTrustPolicy.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_createorder" {
  role       = aws_iam_role.iam_for_createorder.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "ddb_policy" {
  role       = aws_iam_role.iam_for_createorder.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_lambda_function" "lambda" {
    filename        = "create-orders.zip"
    function_name   = "create-order"
    handler         = "index.handler"
    role            = aws_iam_role.iam_for_createorder.arn
    runtime         = "nodejs12.x"

    environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.orders_table.name
    }
  }
}

# Cloud 9 Development environment
resource "aws_cloud9_environment_ec2" "development" {
  name                        = "c9-dev"
  instance_type               = "t3.small"
}
