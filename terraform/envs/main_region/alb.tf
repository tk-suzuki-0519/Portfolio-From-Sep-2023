# -----------------------------------
# ALB(Application Load Balancer)
# -----------------------------------
resource "aws_lb" "alb" {
  name                       = format("%s-alb", var.env_name)
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  ip_address_type            = "ipv4"
  enable_deletion_protection = false
  subnets                    = [for subnet in aws_subnet.public_subnet_alb : subnet.id]
  security_groups            = [aws_security_group.web_sg.id]
  /* 以下デバッグ後、コメントアウトを外す
  access_logs {
    bucket  = aws_s3_bucket.private_sys_logs_with_objectlock.id
    prefix  = "alb"
    enabled = true
  }
  */
  tags = {
    Name = format("%s_alb", var.env_name)
  }
}
resource "aws_lb_target_group" "alb_tg" {
  name        = format("%s-alb-tg", var.env_name)
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc.id
  health_check {
    healthy_threshold   = 3
    interval            = 60
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
  lifecycle {
    create_before_destroy = true
  }
  # depends_on = [aws_lb.alb]
  tags = {
    Name = format("%s_alb_tg", var.env_name)
  }
}
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
  tags = {
    Name = format("%s_alb_http_listener", var.env_name)
  }
}
