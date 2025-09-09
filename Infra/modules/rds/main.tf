##############################################
# RDS module resources - main.tf             #
##############################################

resource "aws_db_subnet_group" "this" {
  name       = "${var.environment}-db-subnets"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "mysql" {
  identifier             = "${var.environment}-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.security_group_ids
  skip_final_snapshot    = true
  publicly_accessible    = false
  storage_encrypted       = true
  backup_retention_period = 7
  tags = { Name = "${var.environment}-rds" }
}
