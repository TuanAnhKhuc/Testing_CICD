##############################################
# Terraform variables for the dev environment #
# Replace placeholders as needed before apply #
##############################################

# AWS & environment
aws_region  = "ap-northeast-1"
environment = "dev"

# Networking (VPC and subnets)
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

# Database (RDS MySQL)
db_name              = "appdb"
db_username          = "appuser"
db_password          = "ChangeMe123!" # change in real use
db_allocated_storage = 20
db_instance_class    = "db.t3.micro"

# ECS cluster
ecs_cluster_name = "dev-ecs-cluster"

# ECS services resources (valid Fargate combos). Adjust as needed
backend_cpu    = 256
backend_memory = 512
frontend_cpu   = 256
frontend_memory = 512

# Container images (replace with your ECR repos/images)
# Example: "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/backend"
backend_image      = "tuananh2410/backend"
backend_image_tag  = "dev-latest"
frontend_image     = "tuananh2410/frontend"
frontend_image_tag = "dev-latest"

# Desired counts
backend_desired_count  = 1
frontend_desired_count = 1

# Route53 / ACM (must exist in your AWS account)
# Set root_domain_name to an existing hosted zone in Route53
root_domain_name = "tudaolw.io.vn"   # change to your domain
subdomain        = "anhkt.dev"           # will produce dev.example.com

# Service discovery (CloudMap)
service_discovery_services = [
  {
    name            = "backend"
    dns_record_type = "A"
    dns_ttl         = 10
    routing_policy  = "MULTIVALUE"
    tags            = {}
  }
]

# ALB target groups (must include groups: frontend, backend)
alb_target_groups = [
  {
    name        = "frontend"
    port        = 80
    protocol    = "HTTP"
    target_type = "ip"
    health_check = {
      path                = "/"
      protocol            = "HTTP"
      healthy_threshold   = 2
      unhealthy_threshold = 5
      timeout             = 5
      interval            = 30
    }
  },
  {
    name        = "backend"
    port        = 80
    protocol    = "HTTP"
    target_type = "ip"
    health_check = {
      path                = "/" # change to /health if your API exposes it
      protocol            = "HTTP"
      healthy_threshold   = 2
      unhealthy_threshold = 5
      timeout             = 5
      interval            = 30
    }
  }
]
