variable "environment" {
  description = "Tên môi trường (dev/uat/prod)"
  type        = string
}

variable "private_subnet_ids" {
  description = "Danh sách private subnet IDs"
  type        = list(string)
}

variable "rds_sg_id" {
  description = "Security group ID cho RDS"
  type        = string
}

variable "db_instance_class" {
  description = "Loại instance cho RDS"
  type        = string
}

variable "db_allocated_storage" {
  description = "Dung lượng storage (GB)"
  type        = number
}

variable "db_name" {
  description = "Tên database"
  type        = string
}

variable "db_username" {
  description = "Tên user database"
  type        = string
}

variable "db_password" {
  description = "Mật khẩu database"
  type        = string
  sensitive   = true
}

variable "common_tags" {
  description = "Tag chuẩn từ module tagging"
  type        = map(string)
}