provider "aws" {
  version = "~> 2.0"
  region = "us-west-2"
}

#The bucket to be encrypted
resource "aws_s3_bucket" "lab_bucket" {
  bucket_prefix = "encrypt-s3-objects-with-managed-keys-"
  force_destroy = true
}

#Make the bucket a private bucket and prevent public access.
resource "aws_s3_bucket_public_access_block" "lab_bucket_privacy" {
  bucket = aws_s3_bucket.lab_bucket.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

#This is the object used for uploading and comparing encrypted vs non-enctryped behavior
resource "aws_s3_bucket_object" "baseline_object" {
  bucket = aws_s3_bucket.lab_bucket.id
  key = "unencrypted"
  source = "./unencrypted"
}

#The bucket with resources for the lab
resource "aws_s3_bucket" "resource_bucket" {
  bucket_prefix = "resources-"
  force_destroy = true
}

#Make the bucket a private bucket and prevent public access.
resource "aws_s3_bucket_public_access_block" "resource_bucket_privacy" {
  bucket = aws_s3_bucket.resource_bucket.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

#An object to be copied to the lab bucket after encryption is configured.
resource "aws_s3_bucket_object" "resource_object" {
  bucket = aws_s3_bucket.resource_bucket.id
  key = "encrypted"
  source = "./unencrypted"
}
