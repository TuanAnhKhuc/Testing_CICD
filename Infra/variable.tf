variable "region" {
  type        = string
  description = "AWS region"
  default     = "ap-southeast-1"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR for VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for private subnets"
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "db_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for DB subnets"
  default     = []
}

variable "enable_https" {
  type        = bool
  description = "Enable HTTPS via ACM + Route53"
  default     = false
}

variable "frontend_image" {
  type        = string
  description = "ECR image URI for frontend"
}

variable "backend_image" {
  type        = string
  description = "ECR image URI for backend"
}

variable "frontend_desired_count" {
  type        = number
  description = "Desired count frontend"
  default     = 1
}

variable "backend_desired_count" {
  type        = number
  description = "Desired count backend"
  default     = 1
}

# DB settings
variable "db_name" {
  type        = string
  description = "Database name"
  default     = "tododb"
}

variable "db_username" {
  type        = string
  description = "Master username"
  default     = "dbuser"
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  type        = number
  description = "RDS storage (GiB)"
  default     = 20
}

variable "engine_version" {
  type        = string
  description = "PostgreSQL engine version"
  default     = "15.5"
}

variable "multi_az" {
  type        = bool
  description = "Enable Multi-AZ for RDS"
  default     = false
}

variable "backup_retention_period" {
  type        = number
  description = "Backup retention days"
  default     = 1
}

variable "deletion_protection" {
  type        = bool
  description = "Enable deletion protection"
  default     = false
}
