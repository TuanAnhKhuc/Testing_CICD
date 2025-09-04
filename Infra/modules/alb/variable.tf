variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnets for ALB"
}

variable "sg_id" {
  type        = string
  description = "SG for ALB"
}

variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN for HTTPS listener"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to ALB"
}
