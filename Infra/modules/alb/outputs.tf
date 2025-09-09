##############################################
# ALB module outputs - outputs.tf            #
##############################################

output "alb_dns_name" {
  description = "DNS name của ALB"
  value       = aws_lb.app.dns_name
}

output "target_group_arns" {
  description = "Map of target group names to their ARNs"
  value       = { for name, tg in aws_lb_target_group.targets : name => tg.arn }
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = aws_lb_listener.https.arn
}

output "alb_zone_id" {
  description = "Zone ID của ALB"
  value       = aws_lb.app.zone_id
}
