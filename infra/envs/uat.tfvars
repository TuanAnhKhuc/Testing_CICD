# ====== ENV / REGION ======
environment       = "uat"
aws_region        = "ap-northeast-1"

# ====== DNS / CERT (Route53 hosted zone phải tồn tại trước) ======
root_domain_name  = "tudaolw.io.vn"   # ví dụ: "anhkt4.online"
subdomain         = "app.anhkt"                     # sẽ tạo app.<root_domain_name>

# ====== NETWORKING ======
vpc_cidr = "10.0.0.0/16"

# 2 public subnets (map vào AZ theo index trong danh sách)
public_subnet_cidrs = [
  "10.0.0.0/24",   # -> ap-northeast-1a
  "10.0.1.0/24",   # -> ap-northeast-1c
]

# 2 private subnets (cho ECS + RDS)
private_subnet_cidrs = [
  "10.0.10.0/24",  # -> ap-northeast-1a
  "10.0.11.0/24",  # -> ap-northeast-1c
]

# ====== RDS (MySQL 8.0) ======
db_instance_class    = "db.t4g.micro"     # rẻ để test; có thể đổi db.t3.micro nếu x86
db_allocated_storage = 20                 # GB
db_name              = "appdb"
db_username          = "appuser"
# db_password        = (đưa vào GitHub Secrets và truyền qua -var)

# ====== ECS / CLUSTER ======
ecs_cluster_name = "uat-ecs-cluster"

# Backend task sizing
backend_cpu            = "256"
backend_memory         = "512"
backend_desired_count  = 1

# Frontend task sizing
frontend_cpu           = "256"
frontend_memory        = "512"
frontend_desired_count = 1

# ====== CONTAINER IMAGES ======
# Với ECR private: "<account_id>.dkr.ecr.ap-northeast-1.amazonaws.com/<repo>"
# Với Docker Hub:  "<username>/<repo>"
backend_image      = "tuananh2410/backend"
backend_image_tag  = "uat-latest"

frontend_image     = "tuananh2410/frontend"
frontend_image_tag = "uat-latest"
