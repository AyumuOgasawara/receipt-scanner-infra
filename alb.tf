resource "aws_lb" "receipt_scanner_alb" {
  name               = "receipt-scanner-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.receipt_scanner_alb_sg.id]

  subnets = [
    for value in aws_subnet.receipt_scanner_sn : value.id
  ]

  ip_address_type = "ipv4"

  tags = {
    Name = "receipt-scanner"
  }
}

resource "aws_lb_target_group" "receipt_scanner_target_group" {
  name             = "receipt-scanner-target-group"
  target_type      = "instance"
  protocol_version = "HTTP1"
  port             = 80
  protocol         = "HTTP"

  vpc_id = aws_vpc.receipt_scanner_vpc.id

  tags = {
    Name = "receipt-scanner"
  }

  health_check {
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200,301"
  }
}

resource "aws_lb_target_group_attachment" "receipt_scanner_target_ec2" {
  target_group_arn = aws_lb_target_group.receipt_scanner_target_group.arn
  target_id        = aws_instance.receipt_scanner_ec2.id
}

## HTTPSのリスナーは手作業で行なっている
