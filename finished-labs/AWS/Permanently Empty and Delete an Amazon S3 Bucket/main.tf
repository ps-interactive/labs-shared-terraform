terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.35.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

provider "aws" {}
provider "random" {}

resource "random_uuid" "uuid" {}

resource "aws_s3_bucket" "bucket" {
  bucket = "mybucket-${random_uuid.uuid.result}"
  acl    = "public-read"

  tags = {
    Name        = "mybucket-${random_uuid.uuid.result}"
    Environment = "lab"
  }
}

resource "aws_s3_bucket_object" "object1" {
  bucket = aws_s3_bucket.bucket.id
  key    = "hello.html"
  source = "src/hello.html"
}

resource "aws_s3_bucket_object" "object2" {
  bucket = aws_s3_bucket.bucket.id
  key    = "hello2.html"
  source = "src/hello2.html"
}

resource "aws_s3_bucket_object" "object3" {
  bucket = aws_s3_bucket.bucket.id
  key    = "hello3.html"
  source = "src/hello3.html"
}

resource "aws_s3_bucket_object" "object4" {
  bucket = aws_s3_bucket.bucket.id
  key    = "myprefix/hello4.html"
  source = "src/hello4.html"
}
