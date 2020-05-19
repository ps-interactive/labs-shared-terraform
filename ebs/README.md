# cloudfront-errors-lab

This Template of sorts provides examples of the following resources:

### vpc.tf

- aws_vpc - The resources below get created automatically
  - Network ACL
  - Route Table
  - Security Group
  - DHCP Options set
- aws_internet_gateway
- aws_route
- aws_subnet

### main.tf

- aws_s3_bucket
- aws_s3_bucket_object
- random_string
- aws_elastic_beanstalk_application
- aws_elastic_beanstalk_application_version
- aws_elastic_beanstalk_environment
- aws_cloudfront_distribution


It also shows examples of the following:

### main.tf

- Uploading a folder to S3
- Generating a Random String