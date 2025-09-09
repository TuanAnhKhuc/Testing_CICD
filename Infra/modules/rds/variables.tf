##############################################
# RDS module variables - variables.tf        #
##############################################

variable "environment" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_group_ids" { type = list(string) }
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}
variable "db_allocated_storage" { type = number }
variable "db_instance_class"   { type = string }
