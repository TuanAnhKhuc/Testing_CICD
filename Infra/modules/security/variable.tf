variable "environment" {
  description = "Tên môi trường (dev/uat/prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID của VPC"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}