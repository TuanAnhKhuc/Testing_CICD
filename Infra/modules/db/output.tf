output "db_endpoint" {
  value = aws_db_instance.postgres.address
}

output "db_sg_id" {
  value = aws_security_group.db.id
}

output "db_secret_arn" {
  value = aws_secretsmanager_secret.db.arn
}
