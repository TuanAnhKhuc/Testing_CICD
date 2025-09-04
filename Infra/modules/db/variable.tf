variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "db_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for RDS"
}

variable "app_sg_id" {
  type        = string
  description = "Security group ID of ECS app to allow inbound"
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "db_username" {
  type        = string
  description = "Master username"
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  type        = number
  description = "Storage size (GiB)"
  default     = 20
}

variable "engine_version" {
  type        = string
  description = "PostgreSQL engine version"
  default     = "15.5"
}

variable "multi_az" {
  type        = bool
  description = "Enable Multi-AZ"
  default     = false
}

variable "backup_retention_period" {
  type        = number
  description = "Backup retention days"
  default     = 1
}

variable "deletion_protection" {
  type        = bool
  description = "Protect DB from deletion"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
}
