variable "environment" { type = string }
variable "aws_region"  { type = string }

# ECS
variable "ecs_cluster_id" { type = string }
variable "ecs_sg_id"      { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "task_exec_role_arn" { type = string }

# Backend
variable "backend_image" { type = string }
variable "backend_image_tag" { type = string }
variable "backend_cpu" { type = string }
variable "backend_memory" { type = string }
variable "backend_desired_count" { type = number }
variable "backend_log_group" { type = string }

# Database connection (cho backend)
variable "db_endpoint" { type = string }
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "db_password" { 
    type = string 
    sensitive = true 
}

# Frontend
variable "frontend_image" { type = string }
variable "frontend_image_tag" { type = string }
variable "frontend_cpu" { type = string }
variable "frontend_memory" { type = string }
variable "frontend_desired_count" { type = number }
variable "frontend_log_group" { type = string }

# ALB Target Groups
variable "backend_tg_arn" { type = string }
variable "frontend_tg_arn" { type = string }

# ALB Listener (https)
variable "https_listener_arn" { type = string }

variable "common_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}