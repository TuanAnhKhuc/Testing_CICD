data "aws_caller_identity" "current" {}

module "tagging" {
  source        = "./modules/tagging"
  environment   = var.environment
  project       = local.project
  owner         = local.owner
  provisioned_by= local.provisioned_by
  extra_tags    = local.extra_tags
}

data "aws_route53_zone" "main" {
  name         = var.root_domain_name
  private_zone = false
}

module "networking" {
  source              = "./modules/networking"
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs= var.private_subnet_cidrs
  common_tags         = module.tagging.common_tags
}

module "security" {
  source      = "./modules/security"
  environment = var.environment
  vpc_id      = module.networking.vpc_id
  common_tags         = module.tagging.common_tags
}


module "rds" {
  source               = "./modules/rds"
  environment          = var.environment
  private_subnet_ids   = module.networking.private_subnet_ids
  rds_sg_id            = module.security.rds_sg_id
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  common_tags         = module.tagging.common_tags
}

module "ecs" {
  source      = "./modules/ecs"
  environment = var.environment
  common_tags         = module.tagging.common_tags
}

module "alb" {
  source            = "./modules/alb"
  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  alb_sg_id         = module.security.alb_sg_id
  public_subnet_ids = module.networking.public_subnet_ids

  root_domain_name = var.root_domain_name
  subdomain        = var.subdomain
  route53_zone_id  = data.aws_route53_zone.main.zone_id
  common_tags         = module.tagging.common_tags
}

module "service" {
  source      = "./modules/service"
  environment = var.environment
  aws_region  = var.aws_region

  ecs_cluster_id     = module.ecs.ecs_cluster_id
  ecs_sg_id          = module.security.ecs_sg_id
  private_subnet_ids = module.networking.private_subnet_ids
  task_exec_role_arn = module.ecs.task_exec_role_arn

  # Backend
  backend_image         = var.backend_image
  backend_image_tag     = var.backend_image_tag
  backend_cpu           = var.backend_cpu
  backend_memory        = var.backend_memory
  backend_desired_count = var.backend_desired_count
  backend_log_group     = module.ecs.backend_log_group

  # DB connection cho backend
  db_endpoint = module.rds.db_endpoint
  db_name     = module.rds.db_name
  db_username = var.db_username
  db_password = var.db_password

  # Frontend
  frontend_image         = var.frontend_image
  frontend_image_tag     = var.frontend_image_tag
  frontend_cpu           = var.frontend_cpu
  frontend_memory        = var.frontend_memory
  frontend_desired_count = var.frontend_desired_count
  frontend_log_group     = module.ecs.frontend_log_group

  # ALB
  backend_tg_arn     = module.alb.backend_tg_arn
  frontend_tg_arn    = module.alb.frontend_tg_arn
  https_listener_arn = module.alb.https_listener_arn

  common_tags         = module.tagging.common_tags
}

module "db_init" {
  source      = "./modules/db_init"
  environment = var.environment
  aws_region  = var.aws_region

  ecs_cluster_name   = module.ecs.ecs_cluster_name
  ecs_sg_id          = module.security.ecs_sg_id
  task_exec_role_arn = module.ecs.task_exec_role_arn
  private_subnet_ids = module.networking.private_subnet_ids

  db_endpoint = module.rds.db_endpoint
  db_name     = module.rds.db_name
  db_username = var.db_username
  db_password = var.db_password

  db_init_log_group = module.ecs.db_init_log_group

  common_tags         = module.tagging.common_tags
}