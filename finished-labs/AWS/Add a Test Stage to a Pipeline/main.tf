resource "aws_elb" "elb" {
  name = var.elb_name
  availability_zones = [
    for az in var.availability_zones:
    az
  ]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval = 5
  }

  instances = [
    for instance in aws_instance.web:
    instance.id
  ]
  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = false
  security_groups = [aws_security_group.lab_user_access.id]

  tags = {
    Name = var.elb_name
  }
}

resource "aws_key_pair" "codecommit_user" {
  key_name = "codecommit-user"
  public_key = file("src/codecommit-user.pub")
}

data "aws_ami" "amazon_linux_v2" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-2*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Amazon

}

resource "aws_security_group" "lab_user_access" {
  name = "lab-user-access"

  ingress {
    description = "SSH from the world"
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    self = true
  }

  ingress {
    description = "HTTP from the world"
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    self = true
  }

  egress {
    description = "Unrestricted"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "web" {
  ami = data.aws_ami.amazon_linux_v2.id
  instance_type = var.instance_type
  count = length(var.availability_zones)
  availability_zone = var.availability_zones[count.index]
  user_data = data.template_file.user_data.rendered
  key_name = "codecommit-user"
  vpc_security_group_ids = [aws_security_group.lab_user_access.id]
  iam_instance_profile = aws_iam_instance_profile.web_profile.name

  tags = {
    Name = var.ec2_name
  }
}

data "template_file" "user_data" {
  template = file("src/user_data.tpl")
  vars = {
    region = var.region
    privatekey = file("src/codecommit-user")
    clone_url_ssh = aws_codecommit_repository.web_app_repository.clone_url_ssh
    repository_name = aws_codecommit_repository.web_app_repository.repository_name
    ssh_public_key_id = aws_iam_user_ssh_key.codecommit_user_ssh_key.ssh_public_key_id
    appspec = file("src/appspec.yml")
    buildspec = file("src/buildspec.yml")
    before_install = file("src/before_install.sh")
  }
}

resource "aws_iam_instance_profile" "web_profile" {
  name = "web-profile"
  role = aws_iam_role.web_role.name
}

resource "aws_iam_role" "web_role" {
  name = "web-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "web_role_attach" {
  role = aws_iam_role.web_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_role" "codedeploy_role" {
  name = "CodeDeployRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codedeploy_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.codedeploy_role.name
}

resource "aws_codedeploy_app" "web_app" {
  name = "web-app"
}

resource "aws_codedeploy_deployment_group" "beta" {
  app_name              = aws_codedeploy_app.web_app.name
  deployment_group_name = "beta"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = var.ec2_name
    }
  }
}

resource "aws_codecommit_repository" "web_app_repository" {
  repository_name = "web-app"
  description     = "This is a sample web-app repository"
}

resource "aws_iam_user" "codecommit_user" {
  name = "codecommit-user"
}

resource "aws_iam_user_policy" "codecommit_user_policy" {
  name = "codecommit-user-policy"
  user = aws_iam_user.codecommit_user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codecommit:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_user_ssh_key" "codecommit_user_ssh_key" {
  username = aws_iam_user.codecommit_user.name
  encoding = "SSH"
  public_key = file("src/codecommit-user.pub")
}

resource "random_uuid" "uuid" { }

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "codepipeline-${random_uuid.uuid.result}"
  acl    = "private"
}

resource "aws_iam_role" "codepipeline_role" {
  name = "CodePipelineRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codecommit:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_codepipeline" "codepipeline" {
  name     = "web-app-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = aws_codecommit_repository.web_app_repository.repository_name
        BranchName = "master"
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ApplicationName = aws_codedeploy_app.web_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.beta.deployment_group_name
      }
    }
  }
}


