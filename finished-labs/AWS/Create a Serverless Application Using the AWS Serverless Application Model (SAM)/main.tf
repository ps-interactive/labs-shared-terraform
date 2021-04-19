# Cloud 9 Development environment
resource "aws_cloud9_environment_ec2" "development" {
  name                        = "sam-dev"
  instance_type               = "t3.small"
}