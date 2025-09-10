variable "environment" {
  description = "Tên môi trường (dev/uat/prod)"
  type        = string
}

variable "common_tags" {
  description = "Tag chuẩn từ module tagging"
  type        = map(string)
}