resource "aws_lb_target_group" "service-tg" {
    name = "WebServers"
    port = 80
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default.id
    health_check {
        enabled = true
        interval = 60
        path = "/"
        timeout = 5
    }
}

resource "aws_security_group" "WebServers" {
    name = "WebServers"
    description = "WebServers"
    vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "allow_80" {
    security_group_id = aws_security_group.WebServers.id
    type = "ingress"
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = [
        "0.0.0.0/0",
    ]
}

resource "aws_security_group_rule" "allow_upstream" {
    security_group_id = aws_security_group.WebServers.id
    type = "egress"
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = [
        data.aws_vpc.default.cidr_block,
    ]
}

resource "aws_lb" "service-lb" {
    name = "MyALB"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.WebServers.id]
    subnets = data.aws_subnet_ids.default.ids

    tags = {
        Name = "MyALB"
    }
}

resource "aws_lb_listener" "service-http-only" {
    load_balancer_arn = aws_lb.service-lb.arn
    port = "80"
    protocol = "HTTP"
     default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.service-tg.arn
    }
}
