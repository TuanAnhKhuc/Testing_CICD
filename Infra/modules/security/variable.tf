variable "vpc_id" {
  type        = string
  description = "VPC ID to attach SGs"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to SGs"
}
