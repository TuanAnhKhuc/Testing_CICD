# Hướng dẫn triển khai Frontend & Backend lên AWS ECS Fargate từ đầu đến cuối

Dưới đây là quy trình chi tiết để đưa hai service Frontend (React) và Backend (.NET) lên ECS Fargate, kết nối với database trên Amazon RDS.

## 1. Chuẩn bị môi trường

1. Cài đặt AWS CLI và cấu hình profile với quyền:
   - ECR: push/pull repositories  
   - ECS/ECR: tạo cluster, task, service  
   - ELB: tạo Application Load Balancer  
   - RDS: (nếu cần) tạo database  
2. Cài đặt Docker để build image cục bộ.

---

## 2. Tạo và đẩy Docker image lên Amazon ECR

1. Tạo 2 repository ECR cho backend và frontend:
   ```bash
   aws ecr create-repository --repository-name backend
   aws ecr create-repository --repository-name frontend
   ```
2. Đăng nhập vào ECR:
   ```bash
   aws ecr get-login-password --region us-east-1 \
     | docker login --username AWS --password-stdin 012345678901.dkr.ecr.us-east-1.amazonaws.com
   ```
3. Build và push image Backend:
   ```bash
   cd path/to/api
   docker build -t backend:latest .
   docker tag backend:latest 012345678901.dkr.ecr.us-east-1.amazonaws.com/backend:latest
   docker push 012345678901.dkr.ecr.us-east-1.amazonaws.com/backend:latest
   ```
4. Build và push image Frontend:
   ```bash
   cd path/to/view
   docker build -t frontend:latest .
   docker tag frontend:latest 012345678901.dkr.ecr.us-east-1.amazonaws.com/frontend:latest
   docker push 012345678901.dkr.ecr.us-east-1.amazonaws.com/frontend:latest
   ```

---

## 3. Tạo ECS Cluster

```bash
aws ecs create-cluster --cluster-name my-app-cluster
```

Mặc định ECS sẽ tạo VPC/các subnet con, nhưng bạn có thể dùng VPC hiện có với `--vpc-config`.

---

## 4. Thiết lập Application Load Balancer

1. Tạo **Target Group**:
   - `tg-backend` → protocol HTTP port 80, target type `ip`  
   - `tg-frontend` → protocol HTTP port 80, target type `ip`  
2. Tạo **Application Load Balancer** trong 2 Public Subnets, gán Security Group cho phép HTTP(80) inbound.
3. Tạo Listener HTTP(80) với rule:
   - Path `/api/*` → forward tới `tg-backend`  
   - Default → forward tới `tg-frontend`  

---

## 5. Viết Task Definition

### 5.1 Backend Task Definition (`backend-task.json`)

```json
{
  "family": "backend-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::012345678901:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "backend",
      "image": "012345678901.dkr.ecr.us-east-1.amazonaws.com/backend:latest",
      "portMappings": [{ "containerPort": 80 }],
      "environment": [
        {
          "name": "ConnectionStrings__Database",
          "value": "server=<RDS_ENDPOINT>;port=3306;database=example;user id=root;password=secret"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/backend",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "backend"
        }
      }
    }
  ]
}
```

Đăng ký task:
```bash
aws ecs register-task-definition --cli-input-json file://backend-task.json
```

### 5.2 Frontend Task Definition (`frontend-task.json`)

```json
{
  "family": "frontend-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::012345678901:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "frontend",
      "image": "012345678901.dkr.ecr.us-east-1.amazonaws.com/frontend:latest",
      "portMappings": [{ "containerPort": 80 }],
      "environment": [
        { "name": "APP_API_HOST", "value": "my-alb-xxxxxxxxxx.us-east-1.elb.amazonaws.com" },
        { "name": "APP_API_PORT", "value": "80" }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/frontend",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "frontend"
        }
      }
    }
  ]
}
```

Đăng ký task:
```bash
aws ecs register-task-definition --cli-input-json file://frontend-task.json
```

---

## 6. Tạo ECS Service trên Fargate

### 6.1 Service cho Backend

```bash
aws ecs create-service \
  --cluster my-app-cluster \
  --service-name backend-service \
  --task-definition backend-task \
  --launch-type FARGATE \
  --desired-count 1 \
  --network-configuration 'awsvpcConfiguration={subnets=[subnet-aaa,subnet-bbb],securityGroups=[sg-backend],assignPublicIp=ENABLED}' \
  --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:...:targetgroup/tg-backend/...,containerName=backend,containerPort=80"
```

### 6.2 Service cho Frontend

```bash
aws ecs create-service \
  --cluster my-app-cluster \
  --service-name frontend-service \
  --task-definition frontend-task \
  --launch-type FARGATE \
  --desired-count 1 \
  --network-configuration 'awsvpcConfiguration={subnets=[subnet-aaa,subnet-bbb],securityGroups=[sg-frontend],assignPublicIp=ENABLED}' \
  --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:...:targetgroup/tg-frontend/...,containerName=frontend,containerPort=80"
```

---

## 7. Kiểm thử và theo dõi

- Truy cập DNS của ALB, thử gọi:
  - `https://<ALB>/api/health` → backend  
  - `https://<ALB>/` → frontend  
- Xem logs trên CloudWatch Logs Group `/ecs/backend` và `/ecs/frontend`.  
- Thiết lập Auto Scaling nếu cần (dựa CPU, memory hoặc ALB Request Count).

---

## 8. Mở rộng và CI/CD

- Dùng **AWS CodePipeline** + **CodeBuild**: tự động build→push ECR→deploy ECS.  
- Quản lý secret bằng **AWS Secrets Manager** hoặc **Systems Manager Parameter Store**.  
- Kết hợp **CloudWatch Container Insights** để giám sát metric, logging, tracing.  
- Thử **Blue/Green Deployment** với ECS Deployment Controller hoặc AWS CodeDeploy.

---  

### Thông tin thêm bạn có thể quan tâm

- Cách bảo mật ALB bằng WAF, Shield để chống DDoS.  
- Triển khai HTTPS (ACM Certificate) và redirect HTTP→HTTPS.  
- Dùng **App Mesh** cho service-to-service communication nếu mở rộng microservices.  
- Tối ưu network: đặt task vào private subnet, dùng NAT Gateway hoặc VPC Endpoint để truy cập internet/RDS.  
- Thiết lập CI/CD với GitHub Actions hoặc GitLab CI tương tự.