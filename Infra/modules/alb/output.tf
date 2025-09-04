output "alb_dns" {
  value = aws_lb.this.dns_name
}

output "alb_zone_id" {
  value = aws_lb.this.zone_id
}

output "frontend_tg_arn" {
  value = aws_lb_target_group.frontend.arn
}

output "backend_tg_arn" {
  value = aws_lb_target_group.backend.arn
}
