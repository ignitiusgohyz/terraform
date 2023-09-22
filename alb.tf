# Application Load Balancer
resource "aws_lb" "alb" {
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.subnet_1a.id, aws_subnet.subnet_1b.id, aws_subnet.subnet_1c.id]
  tags = {
    Name = "alb-ig"
  }
}

# Route incoming traffic to ALB target group
resource "aws_lb_listener" "http_redirection" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

# Target group of type EC2 instance
resource "aws_lb_target_group" "target_group" {
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
}

# Security group for ALB (Control traffic)
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.vpc.id

  # HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # From within VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

  # HTTPS from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Out to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg-ig"
  }
}
