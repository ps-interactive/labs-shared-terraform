
#####################
# CREATE EC2 INSTANCE
# refer: https://github.com/ps-interactive/labs-shared-terraform/tree/master/finished-labs/AWS/Create%20and%20Manage%20Users%20with%20AWS%20IAM
# refer: https://letslearndevops.com/2018/08/23/terraform-get-latest-centos-ami/
# refer: https://github.com/ps-interactive/labs-shared-terraform/tree/master/finished-labs/AWS/Scale%20EC2%20Instances%20on%20a%20Schedule
#####################


# REGION HARDCODED
provider "aws" {
  version = "~> 3.7"  
  region = "us-west-2"
}

# REQUESTED VERSION CONSTRAINTS
/*
provider.cloudinit: version = "~> 1.0"
provider.local: version = "~> 1.4"
provider.null: version = "~> 2.1"
provider.random: version = "~> 2.3"
*/

# Open to world
variable "cidr_block_world" {
    default = "0.0.0.0/0"
}

# Restrict to EC2 Instance Connect from us-west-2
data "aws_ip_ranges" "ec2-connect-usw2" {
    regions = ["us-west-2"]
    services = ["ec2_instance_connect"]
}

# Restrict to all AMAZON from us-west-2
data "aws_ip_ranges" "amazon-usw2" {
    regions = ["us-west-2"]
    services = ["amazon"]
}


# cloudinit to add bash commands and powershell
data "cloudinit_config" "install-requirements-config-inline" {
    gzip = true
    base64_encode = true

    part {
        content_type = "text/x-shellscript"
        content = <<-EOF
          #!/bin/bash
          echo "end of config inline"
        EOF
    }
}
data "local_file" "shell_script" {
    filename = "${path.module}/cloud-init-script.sh"
}

data "cloudinit_config" "install-requirements-config-script" {
    gzip = true
    base64_encode = true

    part {
        content_type = "text/x-shellscript"
        content = data.local_file.shell_script.content
    }
}

data "aws_ami" "amazon_linux_v2" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-2*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Amazon

}

###############################
# KEYPAIR for alternate access
###############################

#replace provisioner and provide key file instead
resource "null_resource" "ssh-gen" {
 
  provisioner "local-exec" {
    #command = "apk add openssh; ssh-keygen -q -N \"\" -t rsa -b 4096 -f terrakey; chmod 400 terrakey..pub; ls"
    command = "echo using provided key files"
  }
}
data local_file terrakey-public {
  filename = "./src/lab-ec2.pub"
  depends_on = [null_resource.ssh-gen]
}

data local_file terrakey-private {
    filename = "./src/lab-ec2.key"
    depends_on = [null_resource.ssh-gen]
}

resource "aws_key_pair" "terrakey" {

    key_name = "terrakey"
    public_key = data.local_file.terrakey-public.content
    depends_on = [
        null_resource.ssh-gen
    ]

}



###############################
# SECURITY
###############################


resource "aws_security_group" "ssh-access" {
  name        = "ssh-security-group"
  description = "Allow SSH traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #cidr_blocks = [var.cidr_block_world]
    cidr_blocks = data.aws_ip_ranges.ec2-connect-usw2.cidr_blocks
    
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_block_world]
    #cidr_blocks = data.aws_ip_ranges.amazon-usw2.cidr_blocks #fails, too many ranges

  }

  tags = {
    Name = "SSH Only"
  }
}


####################
# INSTANCE
####################

resource "aws_instance" "lab-ec2" {
    ami                          = data.aws_ami.amazon_linux_v2.id
    instance_type                = "t2.small"
    monitoring                   = false
    # subnet_id                    = aws_subnet.lab_vpc_subnet_a.id
    vpc_security_group_ids       = [aws_security_group.ssh-access.id]
    user_data                    = data.cloudinit_config.install-requirements-config-script.rendered
    key_name                     = aws_key_pair.terrakey.key_name
    # iam_instance_profile = aws_iam_instance_profile.ssm-instance-profile.id

    tags = {
    Name = "Lab-VM"
  }
}




####################
# OUTPUTS
####################

output "ami_id_out" {
  value = data.aws_ami.amazon_linux_v2.id
}

output "ami_arn_out" {
  value = data.aws_ami.amazon_linux_v2.arn
}

output "ami_description_out" {
  value = data.aws_ami.amazon_linux_v2.description
}


output "ami_kernel_id_out" {
  value = data.aws_ami.amazon_linux_v2.kernel_id
}

output "ami_product_codes_out" {
  value = data.aws_ami.amazon_linux_v2.product_codes
}

output "public_ip_out" {
  value = aws_instance.lab-ec2.*.public_ip
}
output "public_dns_out" {
  value = aws_instance.lab-ec2.*.public_dns
}
# output "password_out" {
#   value = aws_instance.lab-ec2.*.password_data
# }
output "fingerprint_out" {
  value = aws_key_pair.terrakey.fingerprint
}
# output "ssh_command_out" {
#   value = format("%s@%s -i %s","ec2-user",aws_instance.lab-ec2.*.public_dns,  data.terrakey-private.filename )
# }
#  ssh ec23-user@ec2-35-164-221-205.us-west-2.compute.amazonaws.com -i .\src\lab-ec2.key
