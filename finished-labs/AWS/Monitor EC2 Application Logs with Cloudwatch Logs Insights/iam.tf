data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" { assume_role_policy = data.aws_iam_policy_document.ec2_assume.json }
resource "aws_iam_role" "lambda" { assume_role_policy = data.aws_iam_policy_document.lambda_assume.json }

data "aws_iam_policy_document" "ec2" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }
}
data "aws_iam_policy_document" "lambda" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.cloudwatch.arn}/*"]
  }
}

resource "aws_iam_policy" "ec2" { policy = data.aws_iam_policy_document.ec2.json }
resource "aws_iam_policy" "lambda" { policy = data.aws_iam_policy_document.lambda.json }

resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ec2.arn
}
resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

resource "aws_iam_instance_profile" "iam" { role = aws_iam_role.ec2.name }
