variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets (ECS)"
}

variable "db_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for DB subnets"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
}
