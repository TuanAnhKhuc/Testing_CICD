##############################################
# Root module wiring - main.tf               #
# - VPC, SG, RDS, Service Discovery          #
# - ALB (frontend default + /api → backend)  #
# - ECS Services & one-off Job               #
##############################################

# Networking: VPC + Subnets
module "vpc" {
  source               = "./modules/vpc"
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# Security Groups (ALB / ECS / Backend-ECS / RDS)
# Note: Module internally allows RDS only from backend ECS SG.
module "security_groups" {
  source      = "./modules/security_groups"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}

# Database (RDS MySQL)
module "rds" {
  source               = "./modules/rds"
  environment          = var.environment
  subnet_ids           = module.vpc.private_subnet_ids
  security_group_ids   = [module.security_groups.rds_sg_id]
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  db_allocated_storage = var.db_allocated_storage
  db_instance_class    = var.db_instance_class
}

# Service Discovery (CloudMap) - internal DNS (e.g., backend.dev.local)
module "service_discovery" {
  source      = "./modules/service_discovery"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  services    = var.service_discovery_services
}

# Public DNS & Certificate (Route53/ACM)
# NOTE: There is currently a dependency with ALB for alias records.
module "route53" {
  source           = "./modules/route53"
  environment      = var.environment
  root_domain_name = var.root_domain_name
  subdomain        = var.subdomain
  alb_dns_name     = module.alb.alb_dns_name
  alb_zone_id      = module.alb.alb_zone_id
}

# Application Load Balancer
# - Default TG: frontend
# - Listener rule: /api/* → backend
module "alb" {
  source                 = "./modules/alb"
  environment            = var.environment
  vpc_id                 = module.vpc.vpc_id
  public_subnet_ids      = module.vpc.public_subnet_ids
  security_group_ids     = [module.security_groups.alb_sg_id]
  certificate_arn        = module.route53.certificate_arn
  certificate_validation = module.route53.certificate_validation
  internal               = false
  ssl_policy             = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  enable_http_listener   = true
  target_groups          = var.alb_target_groups
  default_target_group   = "frontend"
  listener_rules = [
    {
      rule_name     = "api"
      priority      = 10
      path_patterns = ["/api/*"]
      target_group  = "backend"
    }
  ]
}

# ECS Services (Fargate)
# - backend: internal service, receives traffic via ALB /api path
# - frontend: public via ALB default
module "ecs" {
  source             = "./modules/ecs"
  environment        = var.environment
  aws_region         = var.aws_region
  ecs_cluster_name   = var.ecs_cluster_name
  private_subnet_ids = module.vpc.private_subnet_ids
  alb_listener_arn   = module.alb.https_listener_arn
  # Add deployment safeguards and log retention inside module
  services = [
    {
      name                  = "backend"
      cpu                   = var.backend_cpu
      memory                = var.backend_memory
      image                 = var.backend_image
      image_tag             = var.backend_image_tag
      desired_count         = var.backend_desired_count
      security_groups       = [module.security_groups.backend_ecs_sg_id]
      service_discovery_arn = module.service_discovery.service_arns["backend"]
      target_group_arn      = module.alb.target_group_arns["backend"]
      port_mappings         = [{ containerPort = 80, protocol = "tcp" }]
      environment           = [
        {
          name  = "ConnectionStrings__Database"
          value = "server=${module.rds.rds_endpoint};port=3306;database=${var.db_name};user id=${var.db_username};password=${var.db_password}"
        }
      ]
    },
    {
      name                  = "frontend"
      cpu                   = var.frontend_cpu
      memory                = var.frontend_memory
      image                 = var.frontend_image
      image_tag             = var.frontend_image_tag
      desired_count         = var.frontend_desired_count
      security_groups       = [module.security_groups.ecs_sg_id]
      service_discovery_arn = ""
      target_group_arn      = module.alb.target_group_arns["frontend"]
      port_mappings         = [{ containerPort = 80, protocol = "tcp" }]
      environment           = [] # FE calls /api on same domain; ALB routes to backend
    }
  ]
}

# One-off init job (run once to seed DB)
module "job" {
  source             = "./modules/job"
  environment        = var.environment
  aws_region         = var.aws_region
  ecs_cluster_name   = var.ecs_cluster_name
  private_subnet_ids = module.vpc.private_subnet_ids
  task_exec_role_arn = module.ecs.task_exec_role_arn
  tasks = [
    {
      name           = "db-init"
      cpu            = "256"
      memory         = "512"
      image          = "mysql:8.0"
      security_group = module.security_groups.ecs_sg_id
      command        = [
        "mysql",
        "-h${module.rds.rds_endpoint}",
        "-u${var.db_username}",
        "-p${var.db_password}",
        "${var.db_name}",
        "-e",
        "CREATE TABLE IF NOT EXISTS Product (id INTEGER NOT NULL AUTO_INCREMENT, name VARCHAR(50), price DECIMAL(12,2), PRIMARY KEY (id)); INSERT IGNORE INTO Product (name, price) VALUES ('Mobile', 100), ('Tablet', 200), ('Labtop', 300.00), ('Desktop', 400), ('Server', 500);"
      ]
    }
  ]
}
