# [START] input variables
variable "region" {
    type = string
    default = "us-west-2"
}

variable "subnet_id" {
    type = string
    default = ""
}
# [END]


# [START] provider definition
provider "aws" {
    version = "~> 2.0"
    # region = var.region
	region = "us-west-2"
}
# [END]


# [START] AMI definitions
data "aws_ami" "amazon-linux-2" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "name"
        values = ["amzn2-ami-hvm*"]
    }
}
# [END]


# [START] IAM role and instance role profile for SSM
data "aws_iam_policy_document" "assume-role-policy-ec2" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "PluralsightRoleEC2InstanceBaseline" {
  name = "PluralsightRoleEC2InstanceBaseline"
  assume_role_policy = data.aws_iam_policy_document.assume-role-policy-ec2.json
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "PluralsightRoleEC2InstanceBaseline-AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.PluralsightRoleEC2InstanceBaseline.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

resource "aws_iam_instance_profile" "PluralsightRoleEC2InstanceBaseline" {
  name  = "PluralsightRoleEC2InstanceBaseline"
  role = aws_iam_role.PluralsightRoleEC2InstanceBaseline.name
}
# [END]


resource "aws_instance" "Prod-Web-Instance-1" {
    ami                          = data.aws_ami.amazon-linux-2.id
    instance_type                = "t2.micro"
    subnet_id                    = var.subnet_id
    iam_instance_profile         = aws_iam_instance_profile.PluralsightRoleEC2InstanceBaseline.name
    disable_api_termination      = false
    ebs_optimized                = false
    # associate_public_ip_address  = false
    # hibernation                  = false
    # ipv6_address_count           = 0
    # ipv6_addresses               = []
    # private_ip                   = "172.31.37.38"

    root_block_device {
        delete_on_termination = true
        encrypted             = false
        iops                  = 100
        volume_size           = 8
        volume_type           = "gp2"
    }

    tags = {
      Name = "Prod-Web-Instance-1"
    }
}

resource "aws_instance" "Prod-Web-Instance-2" {
    ami                          = data.aws_ami.amazon-linux-2.id
    instance_type                = "t2.micro"
    subnet_id                    = var.subnet_id
    iam_instance_profile         = aws_iam_instance_profile.PluralsightRoleEC2InstanceBaseline.name
    disable_api_termination      = false
    ebs_optimized                = false
    # associate_public_ip_address  = false
    # hibernation                  = false
    # ipv6_address_count           = 0
    # ipv6_addresses               = []
    # private_ip                   = "172.31.37.38"

    root_block_device {
        delete_on_termination = true
        encrypted             = false
        iops                  = 100
        volume_size           = 8
        volume_type           = "gp2"
    }

    tags = {
      Name = "Prod-Web-Instance-2"
    }
}
