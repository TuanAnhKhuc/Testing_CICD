output "ecs_cluster_id" {
  description = "ID của ECS Cluster"
  value       = aws_ecs_cluster.this.id
}

output "ecs_cluster_name" {
  description = "Tên ECS Cluster"
  value       = aws_ecs_cluster.this.name
}

output "task_exec_role_arn" {
  description = "ARN của ECS Task Execution Role"
  value       = aws_iam_role.task_exec.arn
}

output "backend_log_group" {
  value = aws_cloudwatch_log_group.backend.name
}

output "frontend_log_group" {
  value = aws_cloudwatch_log_group.frontend.name
}

output "db_init_log_group" {
  value = aws_cloudwatch_log_group.db_init.name
}
