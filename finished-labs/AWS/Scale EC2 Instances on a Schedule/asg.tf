data "cloudinit_config" "httpd-config" {
    gzip = true
    base64_encode = true

    part {
        content_type = "text/x-shellscript"
        content = <<-EOF
          #!/bin/bash
          yum update -y
          yum install -y ec2-instance-connect
          yum install -y httpd
          instanceId=$(curl http://169.254.169.254/latest/meta-data/instance-id)
          echo "<h1>Hello World from $instanceId</h1>" > /var/www/html/index.html
          systemctl start httpd
          systemctl enable httpd
        EOF
    }
}

resource "aws_security_group" "ssh-access" {
    name = "ssh-access"
    description = "ssh-access"
    vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "allow_22" {
    security_group_id = aws_security_group.ssh-access.id
    type = "ingress"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = data.aws_ip_ranges.ec2-connect-usw2.cidr_blocks
}

resource "aws_security_group_rule" "allow_egress" {
    security_group_id = aws_security_group.ssh-access.id
    type = "egress"
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_launch_configuration" "MyLC" {
    name = "MyLC"
    image_id = data.aws_ami.latest-amazonlinux2.id
    instance_type = "t3a.small"
    security_groups = [aws_security_group.WebServers.id, aws_security_group.ssh-access.id]
    user_data = data.cloudinit_config.httpd-config.rendered
}

resource "aws_autoscaling_group" "service-scaler" {
    name = "MyASG"
    launch_configuration = aws_launch_configuration.MyLC.name
    min_size = 1 
    max_size = 1
    desired_capacity = 1
    vpc_zone_identifier = data.aws_subnet_ids.default.ids
    target_group_arns = [aws_lb_target_group.service-tg.arn]
    health_check_type = "ELB"
    health_check_grace_period = 60

    tags = [{
                key = "Name"
                value = "ASG-WebServer"
                propagate_at_launch = true
            }]
}
