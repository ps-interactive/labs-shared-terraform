resource "aws_security_group" "nameserver-on-prem" {
    name = "nameserver-on-prem"
    vpc_id = aws_vpc.on-prem.id
}

resource "aws_security_group_rule" "allow_ssh" {
    security_group_id = aws_security_group.nameserver-on-prem.id
    type = "ingress"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = [
        aws_vpc.on-prem.cidr_block,
        data.aws_vpc.default.cidr_block,
    ]
}

resource "aws_security_group_rule" "allow_dns_udp" {
    security_group_id = aws_security_group.nameserver-on-prem.id
    type = "ingress"
    protocol = "udp"
    from_port = 53
    to_port = 53
    cidr_blocks = [
        aws_vpc.on-prem.cidr_block,
        data.aws_vpc.default.cidr_block,

    ]
}

resource "aws_security_group_rule" "allow_dns_tcp" {
    security_group_id = aws_security_group.nameserver-on-prem.id
    type = "ingress"
    protocol = "tcp"
    from_port = 53
    to_port = 53
    cidr_blocks = [
        aws_vpc.on-prem.cidr_block,
        data.aws_vpc.default.cidr_block,
    ]
}

resource "aws_security_group_rule" "allow_ns_egress" {
    security_group_id = aws_security_group.nameserver-on-prem.id
    type = "egress"
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_instance" "nameserver-on-prem" {
    ami = data.aws_ami.latest-ubuntu.id
    private_ip = "192.168.0.53"
    instance_type = "t3a.small"
    subnet_id = aws_subnet.on-prem-private.id
    user_data = data.cloudinit_config.nameserver-config.rendered
    vpc_security_group_ids = [aws_security_group.nameserver-on-prem.id]
    associate_public_ip_address = false

    tags = {
        Name = "nameserver-on-prem"
    }
}

data "template_file" "startup-sh" {
  template = "${file("${path.module}/startup.sh")}"
}

data "cloudinit_config" "nameserver-config" {
    gzip = true
    base64_encode = true

    part {
        content_type = "text/x-shellscript"
        content = data.template_file.startup-sh.rendered
    }
}
