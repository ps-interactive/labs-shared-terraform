resource "aws_instance" "jump-on-prem" {
    ami = data.aws_ami.latest-ubuntu.id
    private_ip = "192.168.0.100"
    instance_type = "t3a.small"
    subnet_id = aws_subnet.on-prem-public.id
    user_data = data.cloudinit_config.jump-on-prem-config.rendered
    vpc_security_group_ids = [aws_security_group.jump-on-prem.id]
    associate_public_ip_address = true

    tags = {
        Name = "jump-on-prem"
    }
}

resource "aws_instance" "jump-cloud" {
    ami = data.aws_ami.latest-ubuntu.id
    instance_type = "t3a.small"
    subnet_id = sort(data.aws_subnet_ids.default.ids)[0]
    user_data = data.cloudinit_config.jump-cloud-config.rendered
    vpc_security_group_ids = [aws_security_group.jump-cloud.id]
    associate_public_ip_address = true

    tags = {
        Name = "jump-cloud"
    }
}

resource "aws_security_group" "jump-on-prem" {
    name = "jump-on-prem"
    vpc_id = aws_vpc.on-prem.id
}

resource "aws_security_group_rule" "allow_on-prem_ec2_connect" {
    security_group_id = aws_security_group.jump-on-prem.id
    type = "ingress"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = data.aws_ip_ranges.ec2-connect-usw2.cidr_blocks
}

resource "aws_security_group_rule" "allow_on-prem_egress" {
    security_group_id = aws_security_group.jump-on-prem.id
    type = "egress"
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "jump-cloud" {
    name = "jump-cloud"
    vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "allow_cloud_ec2_connect" {
    security_group_id = aws_security_group.jump-cloud.id
    type = "ingress"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = data.aws_ip_ranges.ec2-connect-usw2.cidr_blocks
}

resource "aws_security_group_rule" "allow_cloud_egress" {
    security_group_id = aws_security_group.jump-cloud.id
    type = "egress"
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
}

data "cloudinit_config" "jump-on-prem-config" {
    gzip = true
    base64_encode = true

    part {
        content_type = "text/x-shellscript"
        content = <<-EOF
          #!/bin/bash
          apt-get update
          apt-get --no-install-recommends --yes upgrade
          apt-get install --no-install-recommends --yes ec2-instance-connect
          echo "jump.corp.globomantics.com" > /etc/hostname
          hostname jump.corp.globomantics.com
          systemctl disable systemd-resolved.service
          service systemd-resolved stop
          service systemd-resolved status
          mv -v /etc/resolv.conf /etc/resolv.conf.backup
          echo "nameserver 192.168.0.53" > /etc/resolv.conf
          mkdir -p /home/ubuntu/.ssh
          su -c 'echo "StrictHostKeyChecking accept-new" > /home/ubuntu/.ssh/config' ubuntu
        EOF
    }
}

data "cloudinit_config" "jump-cloud-config" {
    gzip = true
    base64_encode = true

    part {
        content_type = "text/x-shellscript"
        content = <<-EOF
          #!/bin/bash
          apt-get update
          apt-get --no-install-recommends --yes upgrade
          apt-get install --no-install-recommends --yes ec2-instance-connect
          echo "jump.prod.globomantics.com" > /etc/hostname
          hostname jump.prod.globomantics.com
        EOF
    }
}
