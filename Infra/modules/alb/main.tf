resource "aws_lb" "app" {
  name               = "${var.environment}-alb"
  load_balancer_type = "application"
  internal           = var.internal
  security_groups    = var.security_group_ids
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "targets" {
  for_each = { for tg in var.target_groups : tg.name => tg }

  name        = "${var.environment}-tg-${each.value.name}"
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = var.vpc_id
  target_type = each.value.target_type

  health_check {
    path                = each.value.health_check.path
    protocol            = each.value.health_check.protocol
    healthy_threshold   = each.value.health_check.healthy_threshold
    unhealthy_threshold = each.value.health_check.unhealthy_threshold
    timeout             = each.value.health_check.timeout
    interval            = each.value.health_check.interval
  }

  tags = { Name = "${var.environment}-tg-${each.value.name}" }
}

resource "aws_lb_listener" "http" {
  count             = var.enable_http_listener ? 1 : 0
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targets[var.default_target_group].arn
  }
  depends_on = [var.certificate_validation]
}

resource "aws_lb_listener_rule" "https_rules" {
  for_each     = { for rule in var.listener_rules : rule.rule_name => rule }
  listener_arn = aws_lb_listener.https.arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targets[each.value.target_group].arn
  }

  condition {
    path_pattern {
      values = each.value.path_patterns
    }
  }
}
