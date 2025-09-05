variable "subnet_id" {
  description = "Subnet ID for the EC2 instance (private subnet)"
  type        = string
}

variable "sg_id" {
  description = "Security Group ID to attach to the EC2 instance"
  type        = string
}

variable "tags" {
  description = "Common tags to apply"
  type        = map(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "frontend_image" {
  description = "Container image for frontend"
  type        = string
}

variable "backend_image" {
  description = "Container image for backend"
  type        = string
}

variable "backend_db_secret_arn" {
  description = "Secrets Manager ARN for DB connection string"
  type        = string
  default     = ""
}

variable "frontend_target_group_arn" {
  description = "ALB target group ARN for frontend"
  type        = string
}

variable "backend_target_group_arn" {
  description = "ALB target group ARN for backend"
  type        = string
}

