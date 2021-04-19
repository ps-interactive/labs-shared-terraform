terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {}

resource "aws_sns_topic" "my_topic" {
  name = "my-sns-topic"
}
