provider "aws" {
  version = "~> 2.0"
  region  = "us-west-2"
}

resource "random_string" "bucket_name" {
  length  = 8
  upper   = false
  lower   = true
  number  = true
  special = false
}


resource "aws_s3_bucket" "lab_resources_public" {
  bucket = "lab-resources-public-${random_string.bucket_name.result}"
  acl    = "public"
}

resource "aws_s3_bucket_object" "public_file" {
  bucket = aws_s3_bucket.lab_resources_public.bucket
  key    = "resource_public.txt"
  source = "${path.cwd}/resource_public.txt"
}


resource "aws_s3_bucket" "lab_resources_private" {
  bucket = "lab-resources-private-${random_string.bucket_name.result}"
  acl    = "private"
}

resource "aws_s3_bucket_object" "private_file" {
  bucket = aws_s3_bucket.lab_resources_private.bucket
  key    = "resource_private.txt"
  source = "${path.cwd}/resource_private.txt"
}
