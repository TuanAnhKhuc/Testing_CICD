terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

resource "aws_security_group" "db" {
  name        = "${var.tags["Project"]}-rds-sg"
  description = "RDS PostgreSQL SG"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.tags["Project"]}-rds-subnet-group"
  subnet_ids = var.db_subnet_ids
  tags       = var.tags
}

resource "random_password" "db" {
  length  = 20
  special = true
  # Exclude '/', '@', '"', and space per RDS password rules
  override_special = "!#$%^&*()-_=+[]{}<>:;,.?|"
}

resource "aws_db_instance" "postgres" {
  identifier                = "${var.tags["Project"]}-postgres"
  engine                    = "postgres"
  instance_class            = var.db_instance_class
  allocated_storage         = var.allocated_storage
  db_name                   = var.db_name
  username                  = var.db_username
  password                  = random_password.db.result
  db_subnet_group_name      = aws_db_subnet_group.this.name
  vpc_security_group_ids    = [aws_security_group.db.id]
  port                      = 5432
  publicly_accessible       = false
  multi_az                  = var.multi_az
  backup_retention_period   = var.backup_retention_period
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = true
  auto_minor_version_upgrade = true

  tags = var.tags
}

resource "aws_secretsmanager_secret" "db" {
  name = "${var.tags["Project"]}-db-conn"
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = "Host=${aws_db_instance.postgres.address};Database=${var.db_name};Username=${var.db_username};Password=${random_password.db.result}"
}
