provider "aws" { region = "us-west-2" }
data "aws_region" "current" {}

data "aws_iam_policy_document" "_" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "_" {
  name               = "sagemaker"
  assume_role_policy = data.aws_iam_policy_document._.json
}

resource "aws_iam_role_policy_attachment" "_" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
  role       = aws_iam_role._.name
}

resource "random_string" "_" {
  length  = 16
  special = false
  upper   = false
}

resource "aws_codecommit_repository" "_" {
  repository_name = "sagemaker-${random_string._.result}"
}

resource "null_resource" "_" {
  provisioner "local-exec" {
    command = "aws codecommit put-file --region ${data.aws_region.current.name} --repository-name ${aws_codecommit_repository._.repository_name} --branch-name main --file-content fileb://notebook.ipynb --file-path notebook.ipynb"
  }
}
