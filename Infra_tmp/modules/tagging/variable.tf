variable "environment" {
  description = "Tên môi trường (dev/uat/prod)"
  type        = string
}

variable "owner" {
  description = "Người sở hữu (team, cá nhân)"
  type        = string
}

variable "project" {
  description = "Tên project"
  type        = string
}

variable "provisioned_by" {
  description = "Ai provision resource (vd: Terraform, DevOps)"
  type        = string
}

variable "extra_tags" {
  description = "Custom tags bổ sung cho từng môi trường"
  type        = map(string)
  default     = {}
}
