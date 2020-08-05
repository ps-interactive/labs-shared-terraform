# lb_tg.tf

resource "aws_lb" "load_balancer" {
  name               = "lab-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [for subnet in aws_subnet.subnets: subnet.id]
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn  = aws_lb.load_balancer.arn
  for_each           = var.forwarding_port
  port               = each.key
  protocol           = each.value

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "tg" {
  name        = "target-group"
  port        = "80"
  protocol    = "TCP"
  vpc_id      = aws_vpc.lab_vpc.id
  target_type = "instance"
}

resource "aws_lb_target_group_attachment" "first_tier_tg" {
  for_each         = aws_instance.first_tier
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.first_tier[each.key].id
  port             = 80
}
