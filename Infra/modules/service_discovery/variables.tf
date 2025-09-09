##############################################
# Service Discovery variables - variables.tf  #
##############################################

variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "services" {
  description = "List of services to register with CloudMap"
  type = list(object({
    name           = string
    dns_record_type = string
    dns_ttl        = number
    routing_policy = string
    tags           = map(string)
  }))
}
#   example = [
#     {
#       name           = "backend"
#       dns_record_type = "A"
#       dns_ttl        = 10
#       routing_policy = "MULTIVALUE"
#       tags           = {}
#     }
#   ]
