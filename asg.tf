# Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.subnet_1a.id, aws_subnet.subnet_1b.id, aws_subnet.subnet_1c.id]
  health_check_type   = "ELB"
  launch_template {
    id      = aws_launch_template.windows_template.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.target_group.arn]
}
