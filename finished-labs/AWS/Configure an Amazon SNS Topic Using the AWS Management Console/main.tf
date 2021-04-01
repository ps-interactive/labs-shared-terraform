provider "aws" {
  version = "~> 2.0"
  region = "us-west-2"
}

resource "aws_sqs_queue" "terraform_queue" {
  name                      = "order-fulfillment-queue"
}