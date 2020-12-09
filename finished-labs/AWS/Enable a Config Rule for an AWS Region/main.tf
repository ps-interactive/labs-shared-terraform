/*
REST API
*/
resource aws_api_gateway_rest_api booking_api {
  name = "booking-api"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

/*
/booking Resource
*/
resource aws_api_gateway_resource booking_api {
  rest_api_id = aws_api_gateway_rest_api.booking_api.id
  parent_id = aws_api_gateway_rest_api.booking_api.root_resource_id
  path_part = "booking"
}

/*
GET /booking Method Request
*/
resource aws_api_gateway_method booking_api {
  rest_api_id = aws_api_gateway_resource.booking_api.rest_api_id
  resource_id = aws_api_gateway_resource.booking_api.id
  authorization = "NONE"
  http_method = "GET"
}

/*
MOCK Integration Request
Mock response with the HTTP Status Code set to 200
*/
resource aws_api_gateway_integration booking_api {
  rest_api_id = aws_api_gateway_method.booking_api.rest_api_id
  resource_id = aws_api_gateway_method.booking_api.resource_id
  http_method = aws_api_gateway_method.booking_api.http_method
  type = "MOCK"
  request_templates = {
    "application/json" = <<TEMPLATE
{
  "statusCode": 200
}
TEMPLATE
  }
}

/*
Method Response
Pass through anything with an HTTP Status Code of 200
*/
resource aws_api_gateway_method_response booking_api {
  rest_api_id = aws_api_gateway_method.booking_api.rest_api_id
  resource_id = aws_api_gateway_method.booking_api.resource_id
  http_method = aws_api_gateway_method.booking_api.http_method
  status_code = 200
}

/*
Integration Response
*/
resource aws_api_gateway_integration_response booking_api {
  rest_api_id = aws_api_gateway_integration.booking_api.rest_api_id
  resource_id = aws_api_gateway_integration.booking_api.resource_id
  http_method = aws_api_gateway_integration.booking_api.http_method
  status_code = 200
  response_templates = {
    "application/json" = <<TEMPLATE
{
    "message": "Booking API"
}
TEMPLATE
  }
}

/*
REST API Deployment
*/
resource aws_api_gateway_deployment booking_api {
  depends_on = [
    aws_api_gateway_integration.booking_api]
  rest_api_id = aws_api_gateway_rest_api.booking_api.id

  stage_name = "demo"
}


/*
REST API
*/
resource aws_api_gateway_rest_api payment_api {
  name = "payment-api"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

/*
/payment Resource
*/
resource aws_api_gateway_resource payment_api {
  rest_api_id = aws_api_gateway_rest_api.payment_api.id
  parent_id = aws_api_gateway_rest_api.payment_api.root_resource_id
  path_part = "payment"
}

/*
GET /payment Method Request
*/
resource aws_api_gateway_method payment_api {
  rest_api_id = aws_api_gateway_resource.payment_api.rest_api_id
  resource_id = aws_api_gateway_resource.payment_api.id
  authorization = "NONE"
  http_method = "GET"
}

/*
MOCK Integration Request
Mock response with the HTTP Status Code set to 200
*/
resource aws_api_gateway_integration payment_api {
  rest_api_id = aws_api_gateway_method.payment_api.rest_api_id
  resource_id = aws_api_gateway_method.payment_api.resource_id
  http_method = aws_api_gateway_method.payment_api.http_method
  type = "MOCK"
  request_templates = {
    "application/json" = <<TEMPLATE
{
  "statusCode": 200
}
TEMPLATE
  }
}

/*
Method Response
Pass through anything with an HTTP Status Code of 200
*/
resource aws_api_gateway_method_response payment_api {
  rest_api_id = aws_api_gateway_method.payment_api.rest_api_id
  resource_id = aws_api_gateway_method.payment_api.resource_id
  http_method = aws_api_gateway_method.payment_api.http_method
  status_code = 200
}

/*
Integration Response
*/
resource aws_api_gateway_integration_response payment_api {
  rest_api_id = aws_api_gateway_integration.payment_api.rest_api_id
  resource_id = aws_api_gateway_integration.payment_api.resource_id
  http_method = aws_api_gateway_integration.payment_api.http_method
  status_code = 200
  response_templates = {
    "application/json" = <<TEMPLATE
{
    "message": "Payment API"
}
TEMPLATE
  }
}

/*
REST API Deployment
*/
resource aws_api_gateway_deployment payment_api {
  depends_on = [
    aws_api_gateway_integration.payment_api]
  rest_api_id = aws_api_gateway_rest_api.payment_api.id

  stage_name = "demo"
}

resource "aws_cloudwatch_log_group" "booking-api" {
  name = "/aws/apigateway/booking-api"
}

resource "aws_cloudwatch_log_group" "ec2" {
  name = "/aws/ec2/instance1"
}

resource "aws_cloudwatch_log_group" "lambda" {
  name = "/aws/lambda/booking-function"
}

resource "aws_cloudwatch_log_group" "payment-api" {
  name = "/aws/lambda/payment-api"
  retention_in_days=5
}
