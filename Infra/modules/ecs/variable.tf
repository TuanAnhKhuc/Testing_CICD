variable "vpc_id" {
  type        = string
  description = "VPC ID for ECS networking"
}

variable "subnets" {
  type        = list(string)
  description = "Private subnet IDs for ECS tasks"
}

variable "sg_id" {
  type        = string
  description = "SG ID for ECS tasks"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to ECS resources"
}

# Optional: pre-created execution role ARN. If empty, module will create one.
variable "execution_role_arn" {
  type        = string
  description = "Existing ECS task execution role ARN"
  default     = ""
}

# Frontend service config
variable "frontend_image" {
  type        = string
  description = "Docker image for frontend"
}

variable "frontend_container_name" {
  type        = string
  description = "Container name for frontend"
  default     = "frontend"
}

variable "frontend_container_port" {
  type        = number
  description = "Container port for frontend"
  default     = 80
}

variable "frontend_desired_count" {
  type        = number
  description = "Desired count for frontend service"
  default     = 1
}

variable "frontend_target_group_arn" {
  type        = string
  description = "Target group ARN for frontend"
}

# Backend service config
variable "backend_image" {
  type        = string
  description = "Docker image for backend"
}

variable "backend_container_name" {
  type        = string
  description = "Container name for backend"
  default     = "apiservice"
}

variable "backend_container_port" {
  type        = number
  description = "Container port for backend"
  default     = 8080
}

variable "backend_desired_count" {
  type        = number
  description = "Desired count for backend service"
  default     = 1
}

variable "backend_target_group_arn" {
  type        = string
  description = "Target group ARN for backend"
}

variable "backend_db_secret_arn" {
  type        = string
  description = "Secrets Manager ARN storing DB connection string"
  default     = ""
}
