output "alb_sg_id" {
  description = "Security group ID cho ALB"
  value       = aws_security_group.alb.id
}

output "ecs_sg_id" {
  description = "Security group ID cho ECS"
  value       = aws_security_group.ecs.id
}

output "rds_sg_id" {
  description = "Security group ID cho RDS"
  value       = aws_security_group.rds.id
}
