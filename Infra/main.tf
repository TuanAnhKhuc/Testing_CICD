module "tagging" {
  source      = "./modules/tagging"
  name_prefix = var.name_prefix
}

module "vpc" {
  source               = "./modules/vpc"
  cidr_block           = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  db_subnet_cidrs      = var.db_subnet_cidrs
  tags                 = module.tagging.tags
}

module "security" {
  source = "./modules/security"
  vpc_id = module.vpc.vpc_id
  tags   = module.tagging.tags
}

# ACM certificate via Route53 DNS validation (requires Route53 zone)
module "acm" {
  source         = "./modules/acm"
  domain_name    = var.domain_name
  hosted_zone_id = var.hosted_zone_id
  tags           = module.tagging.tags
}

module "alb" {
  source         = "./modules/alb"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnet_ids
  sg_id          = module.security.sg_alb_id
  certificate_arn = module.acm.certificate_arn
  tags           = module.tagging.tags
}

# IAM execution role (optional). If you prefer central IAM, expose its ARN and pass to ECS.
module "iam" {
  source      = "./modules/iam"
  name_prefix = var.name_prefix
}

module "ecs" {
  source                    = "./modules/ecs"
  vpc_id                    = module.vpc.vpc_id
  subnets                   = module.vpc.private_subnet_ids
  sg_id                     = module.security.sg_app_id
  tags                      = module.tagging.tags
  execution_role_arn        = module.iam.ecs_task_execution_role_arn

  # Frontend
  frontend_image            = var.frontend_image
  frontend_container_name   = "frontend"
  frontend_container_port   = 80
  frontend_desired_count    = var.frontend_desired_count
  frontend_target_group_arn = module.alb.frontend_tg_arn

  # Backend
  backend_image             = var.backend_image
  backend_container_name    = "apiservice"
  backend_container_port    = 8080
  backend_desired_count     = var.backend_desired_count
  backend_target_group_arn  = module.alb.backend_tg_arn
  backend_db_secret_arn     = try(module.db.db_secret_arn, "")
}

# RDS PostgreSQL + Secret
module "db" {
  source               = "./modules/db"
  vpc_id               = module.vpc.vpc_id
  db_subnet_ids        = module.vpc.db_subnet_ids
  app_sg_id            = module.security.sg_app_id
  tags                 = module.tagging.tags

  db_name              = var.db_name
  db_username          = var.db_username
  db_instance_class    = var.db_instance_class
  allocated_storage    = var.allocated_storage
  engine_version       = var.engine_version
  multi_az             = var.multi_az
  backup_retention_period = var.backup_retention_period
  deletion_protection  = var.deletion_protection
}

# Route53 alias for ALB (optional, only when domain and zone provided)
resource "aws_route53_record" "alb_alias" {
  count   = var.domain_name != "" && var.hosted_zone_id != "" ? 1 : 0
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = module.alb.alb_dns
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}

# Attach Secrets Manager read policy to the ECS execution role (deterministic ARN)
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "secrets_read_root" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [
      "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.name_prefix}-db-conn*"
    ]
  }
}

resource "aws_iam_role_policy" "ecs_exec_secrets_read" {
  name   = "secrets-read"
  role   = module.iam.ecs_task_execution_role_name
  policy = data.aws_iam_policy_document.secrets_read_root.json
}
