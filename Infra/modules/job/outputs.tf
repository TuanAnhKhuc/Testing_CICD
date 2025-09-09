##############################################
# Job module outputs - outputs.tf            #
##############################################

output "task_arns" {
  description = "Map of task names to their ARNs"
  value       = { for name, task in aws_ecs_task_definition.tasks : name => task.arn }
}
