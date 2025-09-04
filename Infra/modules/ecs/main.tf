locals {
  execution_role_arn = var.execution_role_arn
}

resource "aws_ecs_cluster" "this" {
  name = "${var.tags["Project"]}-cluster"
  tags = var.tags
}

data "aws_region" "current" {}

# CloudWatch Log Groups for containers
resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/${var.tags["Project"]}-frontend"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/${var.tags["Project"]}-backend"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

# Frontend task definition
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.tags["Project"]}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = local.execution_role_arn

  container_definitions = jsonencode([
    {
      name         = var.frontend_container_name
      image        = var.frontend_image
      essential    = true
      portMappings = [{ containerPort = var.frontend_container_port, hostPort = var.frontend_container_port }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.frontend.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "frontend" {
  name            = "${var.tags["Project"]}-frontend"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = var.frontend_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = [var.sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.frontend_target_group_arn
    container_name   = var.frontend_container_name
    container_port   = var.frontend_container_port
  }
}

# Backend task definition
resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.tags["Project"]}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = local.execution_role_arn

  container_definitions = jsonencode([
    {
      name         = var.backend_container_name
      image        = var.backend_image
      essential    = true
      portMappings = [{ containerPort = var.backend_container_port, hostPort = var.backend_container_port }]
      environment  = []
      secrets      = var.backend_db_secret_arn != "" ? [
        {
          name      = "ConnectionStrings__db"
          valueFrom = var.backend_db_secret_arn
        }
      ] : []
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.backend.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "backend" {
  name            = "${var.tags["Project"]}-backend"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.backend_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = [var.sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.backend_target_group_arn
    container_name   = var.backend_container_name
    container_port   = var.backend_container_port
  }
}

