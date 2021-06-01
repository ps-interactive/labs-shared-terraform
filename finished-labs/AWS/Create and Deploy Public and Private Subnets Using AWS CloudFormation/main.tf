// Create and Deploy Public/Private subnets
variable "lab_name" {
  default = "create_deploy_public_private_subnets_using_cloudformation"
}

variable "region" {
  default = "us-west-2"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.region
  //profile = "ps-labs"
}

resource "random_string" "stack_id" {
  length  = 5
  special = false
  number = false
  lower = false
}

resource "aws_cloudformation_stack" "lab_ide_stack" {
  name          = "lab-ide-stack-${random_string.stack_id.result}"
  template_body = <<STACK
  {
    "Resources": {
      "LabIDE": {
        "Type": "AWS::Cloud9::EnvironmentEC2",
        "Properties": {
          "InstanceType": "t3.small",
          "Name": "PS-Labs-${random_string.stack_id.result}",
          "Description": "Create and Deploy Subnets with CF",
          "Repositories": [
            {
              "PathComponent": "templates",
              "RepositoryUrl": "https://github.com/ps-interactive/lab_aws_create-and-deploy-public-and-private-subnets-using-aws-cloudformation.git"
            }
          ]
        }
      }
    }
  }
  STACK
}
