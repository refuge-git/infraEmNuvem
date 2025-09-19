resource "aws_security_group" "alb_sg" {
  name        = "alb_sg_web_acess"
  description = "Chamadas HTTP na porta 80"
  vpc_id      = var.vpc_id

  ingress {
    description = "Chamadas HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "web-target-group-app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path     = "/"
    protocol = "HTTP"
    matcher  = "200"
  }
}

resource "aws_lb" "alb_principal" {
  name               = "alb-principal"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnet_ids

  tags = {
    Name = "ALBPrincipal"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb_principal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "ec2_1_attach" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = var.ec2_instance_1_id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "ec2_2_attach" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = var.ec2_instance_2_id
  port             = 8080
}