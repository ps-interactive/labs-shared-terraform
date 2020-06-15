provider "aws" { region = "us-west-2" }

locals {
  business = "bumblebee-logic"
}

data "aws_iam_policy_document" "s3_access" {
  statement {
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::${local.business}-*"]
  }
}

resource "aws_iam_policy" "s3_access" {
  name   = "s3-access"
  policy = data.aws_iam_policy_document.s3_access.json
}

resource "aws_iam_group" "s3_access" {
  name = "s3-access"
}

resource "aws_iam_group_policy_attachment" "s3_access" {
  group      = aws_iam_group.s3_access.name
  policy_arn = aws_iam_policy.s3_access.arn
}

resource "aws_iam_user" "test" {
  name = "test-user"
}

resource "aws_iam_user_group_membership" "jdoe_s3_access" {
  user   = aws_iam_user.test.name
  groups = [aws_iam_group.s3_access.name]
}

data "aws_iam_policy_document" "us_west_admin" {
  statement {
    actions   = ["*"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = ["us-west-1", "us-west-2"]
    }
  }
}

resource "aws_iam_user_policy" "us_west_admin" {
  name   = "us-west-admin"
  user   = aws_iam_user.test.name
  policy = data.aws_iam_policy_document.us_west_admin.json
}
