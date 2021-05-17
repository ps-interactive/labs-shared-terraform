provider "aws" {
  version = "~> 3.26"
  region  = "us-west-2"
}

data "aws_subnet" "default" {
  availability_zone = "us-west-2c"
}

resource "aws_neptune_cluster" "_" {
  cluster_identifier                  = "pslab-cluster"
  engine                              = "neptune"
  backup_retention_period             = 5
  skip_final_snapshot                 = true
  iam_database_authentication_enabled = false
  apply_immediately                   = true
}

resource "aws_neptune_cluster_instance" "_" {
  count              = 1
  identifier         = "pslab-cluster-instance"
  cluster_identifier = aws_neptune_cluster._.id
  engine             = "neptune"
  instance_class     = "db.t3.medium"
  apply_immediately  = true
  availability_zone  = data.aws_subnet.default.availability_zone
}