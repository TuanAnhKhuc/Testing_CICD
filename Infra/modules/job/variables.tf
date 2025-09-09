##############################################
# Job module variables - variables.tf        #
##############################################

variable "environment" {
  description = "Environment name for resource naming"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "task_exec_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "tasks" {
  description = "List of one-off ECS tasks to run"
  type = list(object({
    name          = string
    cpu           = string
    memory        = string
    image         = string
    command       = list(string)
    security_group = string
  }))
  default = []
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 7
}
