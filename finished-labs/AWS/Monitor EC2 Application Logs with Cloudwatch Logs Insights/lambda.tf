resource "random_string" "lambda" {
  length  = 16
  special = false
  upper   = false
}
data "archive_file" "lambda" {
  type        = "zip"
  output_path = "lambda.zip"

  source_content_filename = "index.js"
  source_content          = file("index.js")
}
resource "aws_lambda_function" "lambda" {
  function_name    = random_string.lambda.result
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  handler          = "index.handler"
  runtime          = "nodejs12.x"
  role             = aws_iam_role.lambda.arn
  timeout          = 90
  environment {
    variables = {
      ip = aws_instance.instance.public_ip
    }
  }
}
resource "aws_lambda_permission" "lambda" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cloudwatch.arn
}
