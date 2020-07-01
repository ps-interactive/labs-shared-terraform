provider "aws" {
  version = "~> 2.0"
  region  = "us-west-2"
}

resource "random_string" "unique_bucket_name" {
  length  = 8
  upper   = false
  lower   = true
  number  = true
  special = false
}


resource "aws_s3_bucket" "cloudfront_lab_bucket" {
  bucket = "cloudfront-access-${random_string.unique_bucket_name.result}"
}

resource "aws_s3_bucket_object" "public_file" {
  bucket        = aws_s3_bucket.cloudfront_lab_bucket.bucket
  key           = "index.html"
  acl           = "public-read"
  content_type  = "text/html"
  source        = "${path.cwd}/index.html"
}
