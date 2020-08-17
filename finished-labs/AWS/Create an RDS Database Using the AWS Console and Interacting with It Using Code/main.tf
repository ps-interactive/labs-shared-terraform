// Create an RDS Database Using the AWS Console and Interacting with it using the AWS JavaScript SDK
variable "region" {
  default = "us-west-2"
}

provider "aws" {
  version = "~> 2.0"
  region  = var.region
}

resource "random_string" "stack_id" {
  length  = 8
  special = false
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
        "Name": "PS Labs Code",
        "Description": "RDS and JS SDK",
        "Repositories": [
          {
            "PathComponent": "app",
            "RepositoryUrl": "https://github.com/ps-interactive/aws-rds-js-sdk"
          }
        ]
      }
    }
  }
}
STACK
}
