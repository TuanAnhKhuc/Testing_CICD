variable "environment" { type = string }
variable "vpc_cidr" { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }

variable "common_tags" {
  description = "Tag chuẩn từ module tagging"
  type        = map(string)
}