provider "aws" {
  version = "~> 2.0"
  region = "us-west-2"
}

#Creates a role to be used by CodePipeline and CloudFormation
resource "aws_iam_role" "pipeline_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": ["codepipeline.amazonaws.com", "cloudformation.amazonaws.com"]
      }
    }
  ]
}
EOF
  name = "pipeline-role"
  path = "/pipeline/"
}

#Add s3 permissions to the pipeline role.
resource "aws_iam_role_policy_attachment" "s3_attachment" {
    role = aws_iam_role.pipeline_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

#Add CodeCommit permissions to the pipeline role.
resource "aws_iam_role_policy_attachment" "code_commit_attachment" {
    role = aws_iam_role.pipeline_role.name
    policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess"
}

#Add CodePipeline permissions to the pipeline role.
resource "aws_iam_role_policy_attachment" "code_pipeline_attachment" {
    role = aws_iam_role.pipeline_role.name
    policy_arn = "arn:aws:iam::aws:policy/AWSCodePipelineFullAccess"
}

#Add CloudFormation permissions to the pipeline role.
resource "aws_iam_role_policy_attachment" "cloud_formation_attachment" {
    role = aws_iam_role.pipeline_role.name
    policy_arn = "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
}

#Add EC2 permissions to the pipeline role.
resource "aws_iam_role_policy_attachment" "ec2_attachment" {
    role = aws_iam_role.pipeline_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

#Add SSM permissions to the pipeline role.
resource "aws_iam_role_policy_attachment" "ssm_attachment" {
    role = aws_iam_role.pipeline_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

#Add a policy for passing the role.
data "aws_iam_policy_document" "passrole_document" {
  statement {
    sid = "1"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      aws_iam_role.pipeline_role.arn
    ]
  }
}

resource "aws_iam_policy" "passrole_policy" {
  name = "passrole_policy"
  path = "/pipeline/"
  policy = data.aws_iam_policy_document.passrole_document.json
}

resource "aws_iam_role_policy_attachment" "passrole_attachment" {
    role = aws_iam_role.pipeline_role.name
    policy_arn = aws_iam_policy.passrole_policy.arn
}

#Force the bucket name to be unique through a
#random 12-character string that is appended.
resource "random_string" "main" {
  length  = 12
  special = false
  upper   = false
}

#A bucket to hold the canned artifacts used in the lab.  These are
#CloudFormation template files to keep the scope around the mechanics
#and to not overlap other labs.
resource "aws_s3_bucket" "lab_artifacts" {
  bucket = "automate-cloud-infrastructure-with-cloud-formation-${random_string.main.result}"
  force_destroy = true
  tags = {
    Name = "lab_artifacts"
  }
}

#Make the bucket a private bucket and prevent public access.
resource "aws_s3_bucket_public_access_block" "lab_artifacts_privacy" {
  bucket = aws_s3_bucket.lab_artifacts.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

#This is the CloudFormation template used in the first challenge.
resource "aws_s3_bucket_object" "challenge_1_pipeline" {
  bucket = aws_s3_bucket.lab_artifacts.id
  key = "/challenge_1/pipeline.yml"
  source = "./configuration/challenge_1/pipeline.yml"
}

#This is the CloudFormation template used in the second challenge.
resource "aws_s3_bucket_object" "challenge_2_core_infrastructure" {
  bucket = aws_s3_bucket.lab_artifacts.id
  key = "/challenge_2/core_infrastructure.yml"
  source = "./configuration/challenge_2/core_infrastructure.yml"
}

#This is the CloudFormation template used in the third challenge.
resource "aws_s3_bucket_object" "challenge_3_core_infrastructure" {
  bucket = aws_s3_bucket.lab_artifacts.id
  key = "/challenge_3/core_infrastructure.yml"
  source = "./configuration/challenge_3/core_infrastructure.yml"
}

#These are the CloudFormation template and parameters file for the fourth challenge.
resource "aws_s3_bucket_object" "challenge_4_web_infrastructure" {
  bucket = aws_s3_bucket.lab_artifacts.id
  key = "/challenge_4/web_infrastructure.yml"
  source = "./configuration/challenge_4/web_infrastructure.yml"
}

resource "aws_s3_bucket_object" "challenge_4_parameters" {
  bucket = aws_s3_bucket.lab_artifacts.id
  key = "/challenge_4/parameters.json"
  source = "./configuration/challenge_4/parameters.json"
}

#These are the CloudFormation template and parameters file for the fifth challenge.
resource "aws_s3_bucket_object" "challenge_5_web_infrastructure" {
  bucket = aws_s3_bucket.lab_artifacts.id
  key = "/challenge_5/web_infrastructure.yml"
  source = "./configuration/challenge_5/web_infrastructure.yml"
}

resource "aws_s3_bucket_object" "challenge_5_parameters" {
  bucket = aws_s3_bucket.lab_artifacts.id
  key = "/challenge_5/parameters.json"
  source = "./configuration/challenge_5/parameters.json"
}
