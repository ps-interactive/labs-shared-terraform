# AWS Boilerplate
provider "aws" {
  version = "~> 2.0"
  region  = "us-west-2"
}

# Configure a CloudFront Distribution with a custom origin that point to the Load Balancer created above
resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = "" # Add ELB or S3 domain name
    origin_id   = var.origin_id

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
    target_origin_id       = var.origin_id
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
