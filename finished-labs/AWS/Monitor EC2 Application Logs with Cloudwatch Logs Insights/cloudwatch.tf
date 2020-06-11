resource "aws_cloudwatch_event_rule" "cloudwatch" { schedule_expression = "rate(1 minute)" }
resource "aws_cloudwatch_event_target" "cloudwatch" {
  rule = aws_cloudwatch_event_rule.cloudwatch.name
  arn  = aws_lambda_function.lambda.arn
}
resource "aws_cloudwatch_log_group" "cloudwatch" { name = "/aws/lambda/${aws_lambda_function.lambda.function_name}" }
