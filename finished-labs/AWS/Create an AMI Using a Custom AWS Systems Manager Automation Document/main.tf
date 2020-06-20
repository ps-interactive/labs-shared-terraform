provider "aws" {
  version = "~> 2.0"
  region = "us-west-2"
}

data "aws_region" "current" {}

#The VPC used in this lab.
resource "aws_vpc" "lab" {
    cidr_block = "172.16.16.0/24"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "lab"
    }
}

#Instance role to grant SSM permissions to instances
resource "aws_iam_role" "ssm-instance-role" {
    name = "ssm-instance-role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            }
        }
    ]
}
EOF
}

#Full SSM access for the instance role.  Likely broader
#permissions that are needed for this lab.
resource "aws_iam_role_policy_attachment" "ssm-full-permission" {
    role = aws_iam_role.ssm-instance-role.id
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

#Added to troubleshoot inability to launch Systems Manager Sessions
#to the instances in this configuration.  Likely not needed in light
#of the full permissions granted above.
resource "aws_iam_role_policy_attachment" "ssm-managed-instance-core" {
    role = aws_iam_role.ssm-instance-role.id
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#The actual instance profile that contains the ssm-instance-role.
resource "aws_iam_instance_profile" "ssm-instance-profile" {
    name = "ssm-instance-profile"
    role = aws_iam_role.ssm-instance-role.id
}

#An inbound ssl security group for within the VPC
resource "aws_security_group" "vpc-ssl-sg" {
    name = "vpc-ssl-sg"
    description = "Permit ssl traffic in the VPC cidr"
    vpc_id = aws_vpc.lab.id
    ingress {
        description = "SSL from VPC"
        cidr_blocks = [aws_vpc.lab.cidr_block]
        from_port = 443
        to_port = 443
        protocol = "tcp"
    }
    tags = {
        Name = "vpc-ssl-sg"
    }
}

#A general egress rule for within the VPC
resource "aws_security_group" "vpc-egress" {
    name = "vpc-egress"
    description = "Permit all outbound traffic within the vpc"
    vpc_id = aws_vpc.lab.id
    egress {
        description = "Unrestricted egress"
        cidr_blocks = [aws_vpc.lab.cidr_block]
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        
    }
    tags = {
        Name = "unrestricted-egress"
    }
}

#Expose the ssm endpoint within the private address space of the VPC.
resource "aws_vpc_endpoint" "ssm" {
    private_dns_enabled = true
    service_name = "com.amazonaws.${data.aws_region.current.name}.ssm"
    security_group_ids = [aws_security_group.vpc-ssl-sg.id]
    subnet_ids = [aws_subnet.endpoint-a.id, aws_subnet.endpoint-b.id, aws_subnet.endpoint-c.id]
    vpc_id = aws_vpc.lab.id
    vpc_endpoint_type = "Interface"
}

#Expose the ec2messages endpoint within the private address space of the VPC.
resource "aws_vpc_endpoint" "ec2messages" {
    private_dns_enabled = true
    service_name = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
    security_group_ids = [aws_security_group.vpc-ssl-sg.id]
    subnet_ids = [aws_subnet.endpoint-a.id, aws_subnet.endpoint-b.id, aws_subnet.endpoint-c.id]
    vpc_id = aws_vpc.lab.id
    vpc_endpoint_type = "Interface"
}

#Expose the ec2 endpoint within the private address space of the VPC.
resource "aws_vpc_endpoint" "ec2" {
    private_dns_enabled = true
    service_name = "com.amazonaws.${data.aws_region.current.name}.ec2"
    security_group_ids = [aws_security_group.vpc-ssl-sg.id]
    subnet_ids = [aws_subnet.endpoint-a.id, aws_subnet.endpoint-b.id, aws_subnet.endpoint-c.id]
    vpc_id = aws_vpc.lab.id
    vpc_endpoint_type = "Interface"
}

#Expose the smmmessages endpoint within the private address space of the VPC.
resource "aws_vpc_endpoint" "smmmessages" {
    private_dns_enabled = true
    service_name = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
    security_group_ids = [aws_security_group.vpc-ssl-sg.id]
    subnet_ids = [aws_subnet.endpoint-a.id, aws_subnet.endpoint-b.id, aws_subnet.endpoint-c.id]
    vpc_id = aws_vpc.lab.id
    vpc_endpoint_type = "Interface"
}

#Expose the s3 gateway within the private address space of the VPC.
resource "aws_vpc_endpoint" "s3" {
    route_table_ids = [aws_route_table.internal.id]
    service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
    vpc_id = aws_vpc.lab.id
    vpc_endpoint_type = "Gateway"
}

#The route table for the private address space of the VPC
resource "aws_route_table" "internal" {
    vpc_id = aws_vpc.lab.id
    tags = {
        Name = "internal"
    }
}

#A subnet for production traffic in availability zone a
resource "aws_subnet" "prod-internal-a" {
    vpc_id = aws_vpc.lab.id
    cidr_block = "172.16.16.0/26"
    availability_zone = "${data.aws_region.current.name}a"
    tags = {
        Name = "prod-internal-a"
    }
}

#Adding the subnet to the route table for the zone a subnet.
resource "aws_route_table_association" "prod-internal-a" {
    subnet_id = aws_subnet.prod-internal-a.id
    route_table_id = aws_route_table.internal.id
}

#A subnet for production traffic in availability zone b
resource "aws_subnet" "prod-internal-b" {
    vpc_id = aws_vpc.lab.id
    cidr_block = "172.16.16.64/26"
    availability_zone = "${data.aws_region.current.name}b"
    tags = {
        Name = "prod-internal-b"
    }
}

#Adding the subnet to the route table for the zone b subnet.
resource "aws_route_table_association" "prod-internal-b" {
    subnet_id = aws_subnet.prod-internal-b.id
    route_table_id = aws_route_table.internal.id
}

#A subnet for development traffic in availability zone c
resource "aws_subnet" "dev-internal-c" {
    vpc_id = aws_vpc.lab.id
    cidr_block = "172.16.16.128/26"
    availability_zone = "${data.aws_region.current.name}c"
    tags = {
        Name = "dev-internal-c"
    }
}

#Adding the subnet to the route table for the zone c subnet.
resource "aws_route_table_association" "dev-internal-c" {
    subnet_id = aws_subnet.dev-internal-c.id
    route_table_id = aws_route_table.internal.id
}

#A subnet for the endpoints in availability zone a
resource "aws_subnet" "endpoint-a" {
    vpc_id = aws_vpc.lab.id
    cidr_block = "172.16.16.192/28"
    availability_zone = "${data.aws_region.current.name}a"
    tags = {
        Name = "endpoint-a"
    }
}

#Adding the endpoint subnet a to the router
resource "aws_route_table_association" "endpoint-a" {
    subnet_id = aws_subnet.endpoint-a.id
    route_table_id = aws_route_table.internal.id
}

#A subnet for the endpoints in availability zone b
resource "aws_subnet" "endpoint-b" {
    vpc_id = aws_vpc.lab.id
    cidr_block = "172.16.16.208/28"
    availability_zone = "${data.aws_region.current.name}b"
    tags = {
        Name = "endpoint-b"
    }
}

#Adding the endpoint subnet b to the router
resource "aws_route_table_association" "endpoint-b" {
    subnet_id = aws_subnet.endpoint-b.id
    route_table_id = aws_route_table.internal.id
}

#A subnet for the endpoints in availability zone c
resource "aws_subnet" "endpoint-c" {
    vpc_id = aws_vpc.lab.id
    cidr_block = "172.16.16.224/28"
    availability_zone = "${data.aws_region.current.name}c"
    tags = {
        Name = "endpoint-c"
    }
}

#Adding the endpoint subnet c to the router
resource "aws_route_table_association" "endpoint-c" {
    subnet_id = aws_subnet.endpoint-c.id
    route_table_id = aws_route_table.internal.id
}

#Determine the latest AMI for amazon linux 2.
data "aws_ssm_parameter" "latest-amazon-linux-2" {
    name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#Production instance in availability zone a
resource "aws_instance" "prod1" {
    ami = data.aws_ssm_parameter.latest-amazon-linux-2.value
    instance_type = "t2.micro"
    iam_instance_profile = aws_iam_instance_profile.ssm-instance-profile.id
    subnet_id = aws_subnet.prod-internal-a.id
    vpc_security_group_ids = [aws_security_group.vpc-ssl-sg.id, aws_security_group.vpc-egress.id]
    private_ip = "172.16.16.5"
    tags = {
        Environment = "Prod"
        Name = "prod1"
    }
}

#Production instance in availability zone b
resource "aws_instance" "prod2" {
    ami = data.aws_ssm_parameter.latest-amazon-linux-2.value
    instance_type = "t2.micro"
    iam_instance_profile = aws_iam_instance_profile.ssm-instance-profile.id
    subnet_id = aws_subnet.prod-internal-b.id
    vpc_security_group_ids = [aws_security_group.vpc-ssl-sg.id, aws_security_group.vpc-egress.id]
    private_ip = "172.16.16.69"
    tags = {
        Environment = "Prod"
        Name = "prod2"
    }
}

#Development instance in availability zone c
resource "aws_instance" "dev1" {
    ami = data.aws_ssm_parameter.latest-amazon-linux-2.value
    instance_type = "t2.micro"
    iam_instance_profile = aws_iam_instance_profile.ssm-instance-profile.id
    subnet_id = aws_subnet.dev-internal-c.id
    private_ip = "172.16.16.133"
    vpc_security_group_ids = [aws_security_group.vpc-ssl-sg.id, aws_security_group.vpc-egress.id]
    tags = {
        Environment = "Dev"
        Name = "dev1"
    }
}
