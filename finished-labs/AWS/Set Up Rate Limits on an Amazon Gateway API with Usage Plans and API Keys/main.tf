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
#   role= aws_iam_role.iam_for_lambda.id

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
    filename        = "get-analytics.zip"
    function_name   = "get-analytics"
    handler         = "index.handler"
    role            = aws_iam_role.iam_for_lambda.arn
    runtime         = "nodejs14.x"
}

resource "aws_api_gateway_rest_api" "analytics_api" {
  name        = "globomantics-api"
  description = "Globomantics Analytics API"
}

resource "aws_api_gateway_resource" "analytics_api" {
   rest_api_id = aws_api_gateway_rest_api.analytics_api.id
   parent_id   = aws_api_gateway_rest_api.analytics_api.root_resource_id
   path_part   = "analytics"
}

resource "aws_api_gateway_method" "analytics_api" {
   rest_api_id   = aws_api_gateway_rest_api.analytics_api.id
   resource_id   = aws_api_gateway_resource.analytics_api.id
   http_method   = "GET"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "analytics_api" {
   rest_api_id = aws_api_gateway_rest_api.analytics_api.id
   resource_id = aws_api_gateway_method.analytics_api.resource_id
   http_method = aws_api_gateway_method.analytics_api.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.lambda.invoke_arn
}

resource aws_api_gateway_method_response analytics_api {
  rest_api_id = aws_api_gateway_method.analytics_api.rest_api_id
  resource_id = aws_api_gateway_method.analytics_api.resource_id
  http_method = aws_api_gateway_method.analytics_api.http_method
  status_code = 200
  response_models = {
    "application/json" = "Empty"
  }
}

resource aws_api_gateway_integration_response analytics_api {
  rest_api_id = aws_api_gateway_integration.analytics_api.rest_api_id
  resource_id = aws_api_gateway_integration.analytics_api.resource_id
  http_method = aws_api_gateway_integration.analytics_api.http_method
  status_code = 200
  response_templates = {
    "application/json" = ""
  }
}

resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.lambda.function_name
   principal     = "apigateway.amazonaws.com"

   # The "/*/*" portion grants access from any method on any resource
   # within the API Gateway REST API.
   source_arn = "${aws_api_gateway_rest_api.analytics_api.execution_arn}/*/${aws_api_gateway_method.analytics_api.http_method}${aws_api_gateway_resource.analytics_api.path}"
}

resource "aws_api_gateway_deployment" "example" {
   depends_on = [
     aws_api_gateway_integration.analytics_api
   ]

   rest_api_id = aws_api_gateway_rest_api.analytics_api.id
   stage_name  = "prod"
}

# Cloud 9 Development environment
resource "aws_cloud9_environment_ec2" "development" {
  name                        = "api-key-dev"
  instance_type               = "t3.small"
}
