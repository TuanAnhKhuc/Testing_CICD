output "alb_dns_name" {
  description = "DNS name của ALB"
  value       = aws_lb.app.dns_name
}

output "app_url" {
  description = "URL truy cập ứng dụng"
  value       = "https://${var.subdomain}.${var.root_domain_name}"
}

output "rds_endpoint" {
  description = "Endpoint của RDS MySQL"
  value       = aws_db_instance.mysql.address
}