# AWS Boilerplate
provider "aws" {
  version = "~> 2.0"
  region  = "us-west-2"
}

resource "aws_db_instance" "lab_rds" {
  identifier          = "lab-db-instance"
  instance_class      = "db.t2.micro"
  allocated_storage   = 10
  engine              = "mysql"
  engine_version      = "5.7"
  name                = "labdb"
  username            = "labuser"
  password            = "LabPass20"
  skip_final_snapshot = true
}
