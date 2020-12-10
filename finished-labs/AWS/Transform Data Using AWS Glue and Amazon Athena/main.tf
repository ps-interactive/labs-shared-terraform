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

resource "aws_s3_bucket" "lab_resources_private" {
  bucket = "aws-glue-athena-lab-${random_string.bucket_name.result}"
  acl    = "private"
}


resource "aws_s3_bucket_object" "private_file" {
  bucket = aws_s3_bucket.lab_resources_private.bucket
  key    = "input-data/sales.csv"
  source = "${path.cwd}/sales.csv"
}


resource "aws_s3_bucket_object" "private_empty_folder" {
  bucket = aws_s3_bucket.lab_resources_private.bucket
  key    = "output-data/"
  content_type = "application/x-directory"
}
