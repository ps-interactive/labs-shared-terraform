provider "aws" {
  version = "~> 2.0"
  region  = "us-west-2"
}


variable "mime_types" {
  default = {
    txt  = "text/plain"
    html = "text/html"
  }
}


resource "random_string" "bucket_name" {
  length  = 8
  upper   = false
  lower   = true
  number  = true
  special = false
}


resource "aws_s3_bucket" "lab_resources" {
  bucket = "lab-resources-${random_string.bucket_name.result}"
  acl    = "private"
}
resource "aws_s3_bucket_object" "lab_resource_files" {
  for_each     = fileset("${path.cwd}/lab_resources/", "**/*.*")
  bucket       = aws_s3_bucket.lab_resources.bucket
  key          = replace(each.value, "${path.cwd}/lab_resources/", "")
  source       = "${path.cwd}/lab_resources/${each.value}"
  etag         = filemd5("${path.cwd}/lab_resources/${each.value}")
  content_type = lookup(var.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
}
