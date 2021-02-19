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

resource "aws_dynamodb_table" "product_table" {
  name           = "product_table"
  billing_mode   = "PROVISIONED"
  hash_key       = "productId"
  read_capacity  = 2
  write_capacity = 2

  attribute {
    name = "productId"
    type = "S"
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

resource "aws_lambda_function" "lambda_load_products" {
    filename        = "load_products.zip"
    function_name   = "load_products"
    handler         = "index.lambda_handler"
    role            =  aws_iam_role.ddb_role.arn
    runtime         = "python3.8"
    timeout         =  60
    memory_size     =  256

    environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.product_table.name
    }
  }
}

resource "aws_lambda_function" "lambda_read_products" {
    filename        = "read_products.zip"
    function_name   = "read_products"
    handler         = "index.lambda_handler"
    role            =  aws_iam_role.ddb_role.arn
    runtime         = "python3.8"
    timeout         =  300
    memory_size     =  256

    environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.product_table.name
    }
  }
}
