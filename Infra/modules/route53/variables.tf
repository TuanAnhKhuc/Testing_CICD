##############################################
# Route53 module variables - variables.tf     #
##############################################

variable "environment" { type = string }
variable "root_domain_name" { type = string }
variable "subdomain" { type = string }
variable "alb_dns_name" { type = string }
variable "alb_zone_id" { type = string }
