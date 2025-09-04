variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnets for ALB"
}

variable "sg_id" {
  type        = string
  description = "SG for ALB"
}

variable "enable_https" {
  type        = bool
  description = "Enable HTTPS listener and redirect"
  default     = false
}

variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN for HTTPS listener"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to ALB"
}

variable "frontend_health_path" {
  type        = string
  description = "Health check path for frontend TG"
  default     = "/"
}

variable "backend_health_path" {
  type        = string
  description = "Health check path for backend TG"
  default     = "/"
}

variable "health_check_interval" {
  type        = number
  description = "Health check interval seconds"
  default     = 30
}

variable "health_check_timeout" {
  type        = number
  description = "Health check timeout seconds"
  default     = 5
}

variable "health_healthy_threshold" {
  type        = number
  description = "Healthy threshold count"
  default     = 2
}

variable "health_unhealthy_threshold" {
  type        = number
  description = "Unhealthy threshold count"
  default     = 2
}

variable "health_matcher" {
  type        = string
  description = "HTTP codes to match as healthy"
  default     = "200-399"
}
