# AWS Boilerplate
provider "aws" {
  version = "~> 2.0"
  region  = "us-west-2"
}

# Custom Variable for tagging the content types of the files we'll upload
variable "mime_types" {
  default = {
    html  = "text/html"
    css   = "text/css"
    js    = "application/javascript"
    jpg   = "image/jpeg"
    png   = "image/png"
  }
}

# Create an S3 bucket - Bucket names only accept lower case characters and hyphens
resource "aws_s3_bucket" "lab_resources_v1" {
  bucket  = "lab-resources-v1"
}

# Upload the contents of a local folder to an S3 bucket
# Makes sure that each file has an `etag`
# Example of the `fileset`, `filemd5`, `replace`, and `lookup` functions
resource "aws_s3_bucket_object" "lab_resources_v1_files" {
  for_each      = fileset("${path.cwd}/lab_resources_v1/", "**/*.*")
  bucket        = aws_s3_bucket.lab_resources_v1.bucket
  key           = replace(each.value, "${path.cwd}/lab_resources_v1/", "")
  source        = "${path.cwd}/lab_resources_v1/${each.value}"
  etag          = filemd5("${path.cwd}/lab_resources_v1/${each.value}")
  content_type  = lookup(var.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
}

# Requires the `Random` Provider - it is installed by `terraform init`
resource "random_string" "version" {
  length  = 8
  upper   = false
  lower   = true
  number  = true
  special = false
}

# Elastic Beanstalk Application
resource "aws_elastic_beanstalk_application" "carvedrock_app" {
  name        = "carvedrock-app-${random_string.version.result}"
  description = "Carved Rock Flask Application."
}

# S3 bucket with a random name
resource "aws_s3_bucket" "carvedrock_v1" {
  bucket = "carvedrock-v1-${random_string.version.result}"
}

# Upload a single file to S3
resource "aws_s3_bucket_object" "carvedrock_v1_zip" {
  bucket = aws_s3_bucket.carvedrock_v1.id
  key    = "carvedrock_v1.zip"
  source = "carvedrock_v1.zip"
  etag   = filemd5("carvedrock_v1.zip")
}


# Point an Elastic Beanstalk Environment to a custom application in an S3 bucket
resource "aws_elastic_beanstalk_application_version" "carvedrock_app_v1" {
  name        = "carvedrock-app-v1-${random_string.version.result}"
  application = aws_elastic_beanstalk_application.carvedrock_app.name
  bucket      = aws_s3_bucket.carvedrock_v1.id
  key         = aws_s3_bucket_object.carvedrock_v1_zip.id
}

# Configure and Elastic Beanstalk Environment with an application Load Balancer
resource "aws_elastic_beanstalk_environment" "carvedrock_env" {
  name                = "carvedrock-env-${random_string.version.result}"
  application         = aws_elastic_beanstalk_application.carvedrock_app.name
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.9.6 running Python 3.6"
  version_label       = aws_elastic_beanstalk_application_version.carvedrock_app_v1.name

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.lab_vpc.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${aws_subnet.lab_vpc_subnet_a.id}, ${aws_subnet.lab_vpc_subnet_b.id}"
  }

  setting {
      namespace = "aws:ec2:vpc"
      name      = "ELBSubnets"
      value     = "${aws_subnet.lab_vpc_subnet_a.id}, ${aws_subnet.lab_vpc_subnet_b.id}"
  }
  setting {
    name      = "EnvironmentType"
    namespace = "aws:elasticbeanstalk:environment"
    value     = "LoadBalanced"
  }

  setting {
    name      = "InstanceType"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = "t2.micro"
  }

  setting {
    name      = "InstanceTypeFamily"
    namespace = "aws:cloudformation:template:parameter"
    value     = "t2"
  }

  setting {
    name      = "InstanceTypes"
    namespace = "aws:ec2:instances"
    resource  = ""
    value     = "t2.micro, t2.small"
  }

  setting {
    name      = "LoadBalancerType"
    namespace = "aws:elasticbeanstalk:environment"
    resource  = ""
    value     = "application"
  }
}

# Configure a CloudFront Distribution with a custom origin that point to the Load Balancer created above
resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = aws_elastic_beanstalk_environment.carvedrock_env.endpoint_url
    origin_id   = "ELB_carvedrock"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1.2",
      ]
    }
  }

  enabled = true
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "ELB_carvedrock"
    compress               = true
    default_ttl            = 120
    max_ttl                = 120
    min_ttl                = 0
    smooth_streaming       = false
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers                 = []
      query_string            = false
      query_string_cache_keys = []

      cookies {
        forward           = "none"
        whitelisted_names = []
      }
    }
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }
}
