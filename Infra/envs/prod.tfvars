# ====== ENV / REGION ======
environment       = "prod"
aws_region        = "ap-northeast-1"

# ====== DNS / CERT (Route53 hosted zone phải tồn tại trước) ======
root_domain_name  = "tudaolw.io.vn"
subdomain         = "app"   # => app.tudaolw.io.vn

# ====== NETWORKING ======
vpc_cidr = "10.0.0.0/16"

public_subnet_cidrs = [
  "10.0.0.0/24",
  "10.0.1.0/24",
]

private_subnet_cidrs = [
  "10.0.10.0/24",
  "10.0.11.0/24",
]

# ====== RDS (MySQL 8.0) ======
db_instance_class    = "db.t4g.micro"
db_allocated_storage = 20
db_name              = "appdb"
db_username          = "appuser"
# db_password        = (đưa vào GitHub Secrets và truyền qua -var)

# ====== ECS / CLUSTER ======
ecs_cluster_name = "prod-ecs-cluster"

# Backend task sizing
backend_cpu            = "256"
backend_memory         = "512"
backend_desired_count  = 1

# Frontend task sizing
frontend_cpu           = "256"
frontend_memory        = "512"
frontend_desired_count = 1

# ====== CONTAINER IMAGES ======
backend_image      = "tuananh2410/backend"
backend_image_tag  = "main-latest"

frontend_image     = "tuananh2410/frontend"
frontend_image_tag = "main-latest"

