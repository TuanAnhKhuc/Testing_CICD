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

resource "aws_iam_role_policy" "cloudmap_access" {
  name   = "${var.environment}-cloudmap-access"
  role   = aws_iam_role.task_exec.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = [
        "servicediscovery:RegisterInstance",
        "servicediscovery:DeregisterInstance",
        "servicediscovery:DiscoverInstances"
      ]
      Resource  = "*"
    }]
  })
}

resource "aws_cloudwatch_log_group" "services" {
  for_each          = { for svc in var.services : svc.name => svc }
  name              = "/ecs/${var.environment}/${each.value.name}"
  retention_in_days = var.log_retention_days
  tags              = { Name = "${var.environment}-${each.value.name}-logs" }
}

resource "aws_ecs_task_definition" "services" {
  for_each                 = { for svc in var.services : svc.name => svc }
  family                   = "${var.environment}-${each.value.name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = aws_iam_role.task_exec.arn

  container_definitions = jsonencode([{
    name  = each.value.name
    image = "${each.value.image}:${each.value.image_tag}"
    portMappings = each.value.port_mappings
    environment  = each.value.environment
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/${var.environment}/${each.value.name}"
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "services" {
  for_each         = { for svc in var.services : svc.name => svc }
  name             = "${var.environment}-${each.value.name}-svc"
  cluster          = aws_ecs_cluster.this.id
  task_definition  = aws_ecs_task_definition.services[each.key].arn
  desired_count    = each.value.desired_count
  launch_type      = "FARGATE"
  health_check_grace_period_seconds = 60
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = each.value.security_groups
    assign_public_ip = false
  }
  dynamic "service_registries" {
    for_each = each.value.service_discovery_arn != "" ? [1] : []
    content {
      registry_arn = each.value.service_discovery_arn
    }
  }
  dynamic "load_balancer" {
    for_each = each.value.target_group_arn != "" ? [1] : []
    content {
      target_group_arn = each.value.target_group_arn
      container_name   = each.value.name
      container_port   = each.value.port_mappings[0].containerPort
    }
  }
  force_new_deployment = true
}
