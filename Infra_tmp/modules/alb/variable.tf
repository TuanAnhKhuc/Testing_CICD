variable "environment" { type = string }
variable "vpc_id" { type = string }

variable "alb_sg_id" { type = string }
variable "public_subnet_ids" { type = list(string) }

variable "root_domain_name" { type = string }
variable "subdomain" { type = string }
variable "route53_zone_id" { type = string }

variable "common_tags" {
  description = "Tag chuẩn từ module tagging"
  type        = map(string)
}