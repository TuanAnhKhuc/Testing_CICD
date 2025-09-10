resource "aws_db_subnet_group" "this" {
  name       = "${var.environment}-db-subnets"
  subnet_ids = var.private_subnet_ids

  tags = { Name = "${var.environment}-db-subnet-group" }
}

resource "aws_db_instance" "this" {
  identifier             = "${var.environment}-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage

  db_name   = var.db_name
  username  = var.db_username
  password  = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_sg_id]

  skip_final_snapshot    = true
  publicly_accessible    = false
  storage_encrypted       = true
  backup_retention_period = 7

tags = merge(
    var.common_tags,
  { Name = "${var.environment}-db-instance" }
)
}