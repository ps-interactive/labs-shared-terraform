provider "aws" {
  version = "~> 2.0"
  region = "us-west-2"
}

resource "aws_iam_role" "lambda_exec" {
  name = "role-for-globomantics-email-service"

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

resource "aws_api_gateway_rest_api" "lambda-api-gw" {
  name        = "API Gateway REST API"
  description = "Used by the Globomantics email service"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.lambda-api-gw.id
  parent_id   = aws_api_gateway_rest_api.lambda-api-gw.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.lambda-api-gw.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
   rest_api_id = aws_api_gateway_rest_api.lambda-api-gw.id
   resource_id = aws_api_gateway_method.proxy.resource_id
   http_method = aws_api_gateway_method.proxy.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.globomantics-email-service.invoke_arn
 }

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.lambda-api-gw.id
  resource_id   = aws_api_gateway_rest_api.lambda-api-gw.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.lambda-api-gw.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.globomantics-email-service.invoke_arn
}

resource "aws_api_gateway_deployment" "lambda-api-gw-deployment" {
   depends_on = [
     aws_api_gateway_integration.lambda,
     aws_api_gateway_integration.lambda_root,
   ]

   rest_api_id = aws_api_gateway_rest_api.lambda-api-gw.id
   stage_name  = "test"
 }

 resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.globomantics-email-service.function_name
   principal     = "apigateway.amazonaws.com"

   source_arn = "${aws_api_gateway_rest_api.lambda-api-gw.execution_arn}/*/*"
 }

resource "aws_lambda_function" "globomantics-email-service" {
    function_name = "globomantics-email-service"
    role = aws_iam_role.lambda_exec.arn
    runtime = "nodejs12.x"
    filename = "handler.js.zip"
    handler = "main.handler"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm*"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "my-ec2-instance" {
    ami = data.aws_ami.amazon_linux_2.id
    instance_type = "t2.micro"
    user_data = <<EOF
#!/bin/bash
echo ${aws_api_gateway_deployment.lambda-api-gw-deployment.invoke_url} > /tmp/READ_THIS.txt
sudo echo "* * * * * ec2-user /usr/bin/curl --silent ${aws_api_gateway_deployment.lambda-api-gw-deployment.invoke_url}" > /etc/cron.d/per_minute
EOF

    tags = {
      Name = "HelloWorld"
    }
}
