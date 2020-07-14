provider "aws" {
  version = "~> 2.0"
  region  = "us-west-2"
}
resource "random_string" "bucket_name" {
  length  = 8
  lower = true
  number = true
  upper = false
  special = false
}
resource "aws_s3_bucket" "example" {
  bucket = "lambda-s3-plural-${random_string.bucket_name.result}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls   = true
  block_public_policy = true
}
resource "aws_dynamodb_table" "example" {
  name             = "lambda-s3-table"
  hash_key         = "RequestId"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "RequestId"
    type = "S"
  }
}
