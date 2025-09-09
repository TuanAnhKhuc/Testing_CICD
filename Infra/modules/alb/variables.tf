##############################################
# ALB module variables - variables.tf        #
##############################################

variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "security_group_ids" { type = list(string) }
variable "certificate_arn" { type = string }
variable "certificate_validation" { type = any }

variable "internal" {
  description = "Whether the ALB is internal or external"
  type        = bool
  default     = false
}

variable "ssl_policy" {
  description = "SSL policy for the HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "enable_http_listener" {
  description = "Whether to create an HTTP listener"
  type        = bool
  default     = true
}

variable "target_groups" {
  description = "List of target groups to create"
  type = list(object({
    name        = string
    port        = number
    protocol    = string
    target_type = string
    health_check = object({
      path                = string
      protocol            = string
      healthy_threshold   = number
      unhealthy_threshold = number
      timeout             = number
      interval            = number
    })
  }))
}

variable "default_target_group" {
  description = "Name of the default target group for the HTTPS listener"
  type        = string
}

variable "listener_rules" {
  description = "List of listener rules for the HTTPS listener"
  type = list(object({
    rule_name    = string
    priority     = number
    path_patterns = list(string)
    target_group = string
  }))
}
