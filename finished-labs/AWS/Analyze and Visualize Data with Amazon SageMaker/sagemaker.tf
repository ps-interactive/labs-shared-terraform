resource "aws_sagemaker_code_repository" "sagemaker_cloudlab" {
  code_repository_name = "data"

  git_config {
    repository_url = "https://github.com/ps-interactive/lab_aws_analyze-and-visualize-data-with-amazon-sagemaker.git"
  }
}

resource "aws_sagemaker_notebook_instance" "ni" {
  name          = "HousesPricesDataAnalysisInstance"
  role_arn      = aws_iam_role.notebook_instance_role.arn
  instance_type = "ml.t2.medium"
  default_code_repository = aws_sagemaker_code_repository.sagemaker_cloudlab.code_repository_name

  tags = {
    Name = "HousesPricesDataAnalysisInstance"
  }
}

resource "aws_iam_role" "notebook_instance_role" {
  name = "AmazonSageMaker-ExecutionRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "sagemaker.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_policy" "policy" {
  name        = "sagemaker-role-policy"
  description = "sagemaker-role-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.notebook_instance_role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_2" {
  role       = aws_iam_role.notebook_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}