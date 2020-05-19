# Elastic Beanstalk Terraform Template

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

- random_string
- aws_elastic_beanstalk_application
- aws_elastic_beanstalk_application_version
- aws_elastic_beanstalk_environment
