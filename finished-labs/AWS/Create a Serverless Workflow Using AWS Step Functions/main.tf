resource "aws_dynamodb_table" "globoticket_table" {
  name           = "globoticket_table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "booking_id"

  attribute {
    name = "booking_id"
    type = "S"
  }
}

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

resource "aws_iam_role" "ddb_role" {
  name               = "ddb_role"
  assume_role_policy = data.aws_iam_policy_document.AWSLambdaTrustPolicy.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_producttable" {
  role       = aws_iam_role.ddb_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "ddb_policy" {
  role       = aws_iam_role.ddb_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_lambda_function" "lambda_reserve_ticket" {
    filename        = "reserve_ticket.zip"
    function_name   = "reserve_ticket"
    handler         = "index.lambda_handler"
    role            =  aws_iam_role.ddb_role.arn
    runtime         = "python3.8"
    timeout         =  10
    memory_size     =  256
}

resource "aws_lambda_function" "lambda_collect_payment" {
    filename        = "collect_payment.zip"
    function_name   = "collect_payment"
    handler         = "index.lambda_handler"
    role            =  aws_iam_role.ddb_role.arn
    runtime         = "python3.8"
    timeout         =  10
    memory_size     =  256
}

resource "aws_lambda_function" "lambda_refund_payment" {
    filename        = "refund_payment.zip"
    function_name   = "refund_payment"
    handler         = "index.lambda_handler"
    role            =  aws_iam_role.ddb_role.arn
    runtime         = "python3.8"
    timeout         =  10
    memory_size     =  256
}

