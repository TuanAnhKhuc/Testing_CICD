##############################################
# ECS module variables - variables.tf         #
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

variable "alb_listener_arn" {
  description = "ARN of the ALB listener"
  type        = string
}

variable "services" {
  description = "List of ECS services to deploy"
  type = list(object({
    name                  = string
    cpu                   = number
    memory                = number
    image                 = string
    image_tag             = string
    desired_count         = number
    security_groups       = list(string)
    service_discovery_arn = string
    target_group_arn      = string
    port_mappings         = list(object({
      containerPort = number
      protocol      = string
    }))
    environment           = list(map(string))
  }))
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 7
}
