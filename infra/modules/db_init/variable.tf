variable "environment" { type = string }
variable "aws_region"  { type = string }

# ECS
variable "ecs_cluster_name" { type = string }
variable "ecs_sg_id"        { type = string }
variable "task_exec_role_arn" { type = string }
variable "private_subnet_ids" { type = list(string) }

# Database connection
variable "db_endpoint" { type = string }
variable "db_name"     { type = string }
variable "db_username" { type = string }
variable "db_password" { 
    type = string 
    sensitive = true 
}

# Logging
variable "db_init_log_group" { type = string }

variable "common_tags" {
  description = "Tag chuẩn từ module tagging"
  type        = map(string)
}