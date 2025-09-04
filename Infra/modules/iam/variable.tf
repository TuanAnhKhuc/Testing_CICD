variable "name_prefix" {
  type        = string
  description = "Prefix for IAM role"
}

variable "secrets_arns" {
  type        = list(string)
  description = "Secrets ARNs the execution role can read"
  default     = []
}
