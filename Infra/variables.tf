variable "aws_region" {
  description = "Mã vùng AWS"
  type        = string
}

variable "environment" {
  description = "Prefix cho tên resource"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block cho VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Danh sách CIDR public subnet"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Danh sách CIDR private subnet"
  type        = list(string)
}

variable "db_name" {
  description = "Tên database khởi tạo"
  type        = string 
}
variable "db_username" {
  description = "Username master cho RDS"
  type        = string
}

variable "db_password" {
  description = "Password master cho RDS"
  type        = string
  sensitive   = true
}

variable "db_allocated_storage" {
  description = "Dung lượng (GB) cho RDS"
  type        = number
}

variable "db_instance_class" {
  description = "Instance class cho RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "ecs_cluster_name" {
  description = "Tên ECS Cluster"
  type        = string
}

variable "backend_cpu" {
  description = "vCPU cho backend task"
  type        = number
}

variable "backend_memory" {
  description = "Memory (MB) cho backend task"
  type        = number
}

variable "frontend_cpu" {
  description = "vCPU cho frontend task"
  type        = number
}

variable "frontend_memory" {
  description = "Memory (MB) cho frontend task"
  type        = number
}

variable "backend_image" {
  description = "Docker Hub repo cho backend (không kèm tag)"
  type        = string
}

variable "frontend_image" {
  description = "Docker Hub repo cho frontend (không kèm tag)"
  type        = string
}

variable "backend_image_tag" {
  description = "Tag image backend"
  type        = string
}

variable "frontend_image_tag" {
  description = "Tag image frontend"
  type        = string
}

variable "root_domain_name" {
  description = "Tên miền gốc đã đăng ký trên Route 53, ví dụ myapp.xyz"
  type        = string
}

variable "subdomain" {
  description = "Tiền tố subdomain, ví dụ app → app.myapp.xyz"
  type        = string
  default     = "app"
}

variable "frontend_desired_count" {
  description = "Số lượng task chạy đồng thời cho frontend"
  type        = number
}

variable "backend_desired_count" {
  description = "Số lượng task chạy đồng thời cho backend"
  type        = number
}

variable "common_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}