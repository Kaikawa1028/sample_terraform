/**
 * ALB instance
 */
resource "aws_lb" "web" {
  name                       = "${var.project}-${var.env}-lb"
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = false
  # enable_deletion_protection = true

  security_groups = [
    aws_security_group.web_load_balancer.id
  ]

  subnets = [
    aws_subnet.public-primary.id,
    aws_subnet.public-secondary.id,
    aws_subnet.public-tertiary.id
  ]

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.id
    enabled = true
  }
}

/**
 * Listeners
 */
resource "aws_lb_listener" "web_front_end_https" {
  load_balancer_arn = aws_lb.web.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.web.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

/**
 * Listener Rules
 */
resource "aws_lb_listener_rule" "web" {
  listener_arn = aws_lb_listener.web_front_end_https.arn
  priority     = 101

  condition {
    host_header {
      values = ["event-organizer.jp"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_lb_listener_rule" "web_robots_txt" {
  listener_arn = aws_lb_listener.web_front_end_https.arn
  priority     = 97

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"

      message_body = <<ROBOTS
User-agent: *
Disallow: / 
ROBOTS

      status_code = "200"
    }
  }

  condition {
    path_pattern {
      values = ["/robots.txt"]
    }
  }
}

/**
 * Target Group
 */
resource "aws_lb_target_group" "web" {
  name                 = "tg-${var.env}-web"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = aws_vpc.main.id
  target_type          = "ip"
  deregistration_delay = 30
  depends_on           = [aws_lb.web]

  health_check {
    interval = 60
    path     = "/healthcheck"
    port     = 80
    protocol = "HTTP"
    timeout  = 30
    matcher  = "200"
  }
}
