##############################################
# ECS module outputs - outputs.tf            #
##############################################

output "ecs_cluster_id" { value = aws_ecs_cluster.this.id }

output "service_arns" {
  description = "Map of service names to their ARNs"
  value       = { for name, svc in aws_ecs_service.services : name => svc.id }
}

output "task_exec_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.task_exec.arn
}
