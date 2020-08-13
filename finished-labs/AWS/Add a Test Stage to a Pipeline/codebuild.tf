resource "aws_s3_bucket" "codebuild_bucket" {
  bucket = "codebuild-${random_uuid.uuid.result}"
  acl    = "private"
}

resource "aws_iam_role" "codebuild_role" {
  name = "CodeBuildRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_role_policy" {
  role = aws_iam_role.codebuild_role.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": [
        "arn:aws:ec2:*:*:network-interface/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.codebuild_bucket.arn}",
        "${aws_s3_bucket.codebuild_bucket.arn}/*",
        "arn:aws:s3:::codepipeline-*/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "web_app_project" {
  name          = "web-app-build-project"
  description   = "web_app_codebuild_project"
  build_timeout = "5"
  queued_timeout = "5"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

/*  cache {
    type     = "S3"
    location = aws_s3_bucket.codebuild_bucket.bucket
  }
*/
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TEST_URL"
      value = aws_elb.elb.dns_name 
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.codebuild_bucket.id}/build-log"
    }
  }

  source {
    type            = "CODECOMMIT"
    location        = aws_codecommit_repository.web_app_repository.clone_url_http 
    git_clone_depth = 1
  }

  source_version = "master"

  tags = {
    Environment = "Test"
  }
}

