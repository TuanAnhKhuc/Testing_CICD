############################################
# Data sources
############################################
data "aws_availability_zones" "azs" {}
data "aws_caller_identity" "current" {}
data "aws_route53_zone" "main" {
  name         = var.root_domain_name
  private_zone = false
}

############################################
# Networking
############################################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = { Name = "${var.environment}-vpc" }
}

resource "aws_subnet" "public" {
  for_each                = toset(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.azs.names[
    index(var.public_subnet_cidrs, each.value)
  ]
  tags = { Name = "${var.environment}-public-${each.key}" }
}

resource "aws_subnet" "private" {
  for_each          = toset(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = data.aws_availability_zones.azs.names[
    index(var.private_subnet_cidrs, each.value)
  ]
  tags = { Name = "${var.environment}-private-${each.key}" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.environment}-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.environment}-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  vpc  = true
  tags = { Name = "${var.environment}-nat-eip" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id
  tags          = { Name = "${var.environment}-nat-gateway" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "${var.environment}-private-rt" }
}

resource "aws_route_table_association" "private_assoc" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

############################################
# Security Groups
############################################
resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Allow MySQL traffic from ECS"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.environment}-rds-sg" }
}

resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Allow HTTPS to ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.environment}-alb-sg" }
}

resource "aws_security_group" "ecs" {
  name        = "${var.environment}-ecs-sg"
  description = "Allow traffic within ECS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.environment}-ecs-sg" }
}

############################################
# Database
############################################
resource "aws_db_subnet_group" "this" {
  name       = "${var.environment}-db-subnets"
  subnet_ids = values(aws_subnet.private)[*].id
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
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  storage_encrypted       = true
  backup_retention_period = 7

  tags = { Name = "${var.environment}-rds" }
}

############################################
# ECS + IAM
############################################
resource "aws_ecs_cluster" "this" {
  name = var.ecs_cluster_name
}

data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_exec" {
  name               = "${var.environment}-ecs-task-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

resource "aws_iam_role_policy_attachment" "task_exec_policy" {
  role       = aws_iam_role.task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/${var.environment}/backend"
  retention_in_days = 7
  tags              = { Name = "${var.environment}-backend-logs" }
}
resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/${var.environment}/frontend"
  retention_in_days = 7
  tags              = { Name = "${var.environment}-frontend-logs" }
}

############################################
# Backend ECS
############################################
resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.environment}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.backend_cpu
  memory                   = var.backend_memory
  execution_role_arn       = aws_iam_role.task_exec.arn

  container_definitions = jsonencode([{
    name  = "backend"
    image = "${var.backend_image}:${var.backend_image_tag}"
    portMappings = [{ containerPort = 80, protocol = "tcp" }]
    environment = [{
      name  = "ConnectionStrings__Database"
      value = "server=${aws_db_instance.mysql.address};port=3306;database=${var.db_name};user id=${var.db_username};password=${var.db_password}"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/${var.environment}/backend"
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}


resource "aws_ecs_service" "backend" {
  name            = "${var.environment}-backend-svc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.backend_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = values(aws_subnet.private)[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = 80
  }

  force_new_deployment = true
}


############################################
# Frontend ECS
############################################
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.environment}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.frontend_cpu
  memory                   = var.frontend_memory
  execution_role_arn       = aws_iam_role.task_exec.arn

  container_definitions = jsonencode([{
    name  = "frontend"
    image = "${var.frontend_image}:${var.frontend_image_tag}"
    portMappings = [{ containerPort = 80, protocol = "tcp" }]
    # environment = [
    #   { name = "APP_API_HOST", value = "backend.${var.environment}.local" },
    #   { name = "APP_API_PORT", value = "80" }
    # ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/${var.environment}/frontend"
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}


resource "aws_ecs_service" "frontend" {
  name            = "${var.environment}-frontend-svc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = var.frontend_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = values(aws_subnet.private)[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = 80
  }

  depends_on           = [aws_lb_listener.https]
  force_new_deployment = true
}

############################################
# ALB + ACM + Route53 (Frontend only)
############################################
resource "aws_acm_certificate" "app_cert" {
  domain_name       = "${var.subdomain}.${var.root_domain_name}"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  tags = { Name = "${var.environment}-app-cert" }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.app_cert.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "app_cert_validation" {
  certificate_arn         = aws_acm_certificate.app_cert.arn
  validation_record_fqdns = values(aws_route53_record.cert_validation)[*].fqdn
}

resource "aws_lb" "app" {
  name               = "${var.environment}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb.id]
  subnets            = values(aws_subnet.public)[*].id
}

resource "aws_route53_record" "app_alias" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.subdomain
  type    = "A"
  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "app_alias_aaaa" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.subdomain
  type    = "AAAA"
  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb_target_group" "frontend" {
  name        = "${var.environment}-tg-frontend"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
  }
}
resource "aws_lb_target_group" "backend" {
  name        = "${var.environment}-tg-backend"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/api/products"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
  }
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.app_cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
  depends_on = [aws_acm_certificate_validation.app_cert_validation]
}

resource "aws_lb_listener_rule" "api_routing" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}
############################################
# Database Initialization
############################################

# CloudWatch Log Group for DB Init Task
resource "aws_cloudwatch_log_group" "db_init" {
  name              = "/ecs/${var.environment}/db-init"
  retention_in_days = 7
  tags              = { Name = "${var.environment}-db-init-logs" }
}

# ECS Task Definition for DB Initialization
resource "aws_ecs_task_definition" "db_init" {
  family                   = "${var.environment}-db-init"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.task_exec.arn

  container_definitions = jsonencode([{
    name  = "db-init"
    image = "mysql:8.0"
    command = [
      "mysql",
      "-h${aws_db_instance.mysql.address}",
      "-u${var.db_username}",
      "-p${var.db_password}",
      "${var.db_name}",
      "-e",
      "CREATE TABLE IF NOT EXISTS Product (id INTEGER NOT NULL AUTO_INCREMENT, name VARCHAR(50), price DECIMAL(12,2), PRIMARY KEY (id)); INSERT IGNORE INTO Product (name, price) VALUES ('Mobile', 100), ('Tablet', 200), ('Labtop', 300.00), ('Desktop', 400), ('Server', 500);"
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/${var.environment}/db-init"
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

# Ensure the DB init task runs after RDS is ready
resource "null_resource" "run_db_init" {
  depends_on = [aws_db_instance.mysql, aws_cloudwatch_log_group.db_init]

  provisioner "local-exec" {
    command = <<EOT
      aws ecs run-task \
        --cluster ${aws_ecs_cluster.this.name} \
        --task-definition ${aws_ecs_task_definition.db_init.arn} \
        --launch-type FARGATE \
        --network-configuration "awsvpcConfiguration={subnets=[${join(",", values(aws_subnet.private)[*].id)}],securityGroups=[${aws_security_group.ecs.id}],assignPublicIp=DISABLED}" \
        --region ${var.aws_region}
    EOT
  }
}