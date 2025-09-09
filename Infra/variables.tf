##############################################
# Root variables - variables.tf              #
##############################################

variable "aws_region" { type = string }
variable "environment" { type = string }

# Networking
variable "vpc_cidr" { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }

# Database
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}
variable "db_allocated_storage" { type = number }
variable "db_instance_class"   { type = string }

# ECS
variable "ecs_cluster_name" { type = string }
variable "backend_cpu"      { type = number }
variable "backend_memory"   { type = number }
variable "frontend_cpu"     { type = number }
variable "frontend_memory"  { type = number }
variable "backend_image"    { type = string }
variable "frontend_image"   { type = string }
variable "backend_image_tag"  { type = string }
variable "frontend_image_tag" { type = string }
variable "frontend_desired_count" { type = number }
variable "backend_desired_count"  { type = number }

# Observability
variable "log_retention_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 7
}

# DNS / TLS
variable "root_domain_name" { type = string }
variable "subdomain"        { type = string }

# Modules passthrough
variable "service_discovery_services" { type = any }
variable "alb_target_groups"         { type = any }
