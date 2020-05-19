# AWS Boilerplate
provider "aws" {
  version = "~> 2.0"
  region  = "us-west-2"
}

# Requires the `Random` Provider - it is installed by `terraform init`
resource "random_string" "version" {
  length  = 8
  upper   = false
  lower   = true
  number  = true
  special = false
}

# Elastic Beanstalk Application
resource "aws_elastic_beanstalk_application" "carvedrock_app" {
  name        = "carvedrock-app-${random_string.version.result}"
  description = "Carved Rock Flask Application."
}

# S3 bucket with a random name
resource "aws_s3_bucket" "carvedrock_v1" {
  bucket = "carvedrock-v1-${random_string.version.result}"
}

# Upload a single file to S3
resource "aws_s3_bucket_object" "carvedrock_v1_zip" {
  bucket = aws_s3_bucket.carvedrock_v1.id
  key    = "carvedrock_v1.zip"
  source = "carvedrock_v1.zip"
  etag   = filemd5("carvedrock_v1.zip")
}


# Point an Elastic Beanstalk Environment to a custom application in an S3 bucket
resource "aws_elastic_beanstalk_application_version" "carvedrock_app_v1" {
  name        = "carvedrock-app-v1-${random_string.version.result}"
  application = aws_elastic_beanstalk_application.carvedrock_app.name
  bucket      = aws_s3_bucket.carvedrock_v1.id
  key         = aws_s3_bucket_object.carvedrock_v1_zip.id
}

# Configure and Elastic Beanstalk Environment with an application Load Balancer
resource "aws_elastic_beanstalk_environment" "carvedrock_env" {
  name                = "carvedrock-env-${random_string.version.result}"
  application         = aws_elastic_beanstalk_application.carvedrock_app.name
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.9.6 running Python 3.6"
  version_label       = aws_elastic_beanstalk_application_version.carvedrock_app_v1.name

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.lab_vpc.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${aws_subnet.lab_vpc_subnet_a.id}, ${aws_subnet.lab_vpc_subnet_b.id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = "${aws_subnet.lab_vpc_subnet_a.id}, ${aws_subnet.lab_vpc_subnet_b.id}"
  }
  setting {
    name      = "EnvironmentType"
    namespace = "aws:elasticbeanstalk:environment"
    value     = "LoadBalanced"
  }

  setting {
    name      = "InstanceType"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = "t2.micro"
  }

  setting {
    name      = "InstanceTypeFamily"
    namespace = "aws:cloudformation:template:parameter"
    value     = "t2"
  }

  setting {
    name      = "InstanceTypes"
    namespace = "aws:ec2:instances"
    resource  = ""
    value     = "t2.micro, t2.small"
  }

  setting {
    name      = "LoadBalancerType"
    namespace = "aws:elasticbeanstalk:environment"
    resource  = ""
    value     = "application"
  }
}
