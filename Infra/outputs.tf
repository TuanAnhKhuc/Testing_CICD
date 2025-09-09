##############################################
# Root outputs - outputs.tf                  #
##############################################

output "alb_dns_name" {
  description = "DNS name của ALB"
  value       = module.alb.alb_dns_name
}

output "app_url" {
  description = "URL truy cập ứng dụng"
  value       = module.route53.app_url
}

output "rds_endpoint" {
  description = "Endpoint của RDS MySQL"
  value       = module.rds.rds_endpoint
}
