output "db_endpoint" {
  description = "Endpoint của RDS MySQL"
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "Port của RDS MySQL"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Tên database"
  value       = var.db_name
}