##############################################
# One-off ECS task runner - main.tf          #
##############################################

resource "aws_cloudwatch_log_group" "tasks" {
  for_each          = { for task in var.tasks : task.name => task }
  name              = "/ecs/${var.environment}/${each.value.name}"
  retention_in_days = var.log_retention_days
  tags              = { Name = "${var.environment}-${each.value.name}-logs" }
}

resource "aws_ecs_task_definition" "tasks" {
  for_each                 = { for task in var.tasks : task.name => task }
  family                   = "${var.environment}-${each.value.name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = var.task_exec_role_arn

  container_definitions = jsonencode([{
    name  = each.value.name
    image = each.value.image
    command = each.value.command
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

resource "null_resource" "run_tasks" {
  for_each   = { for task in var.tasks : task.name => task }
  depends_on = [aws_cloudwatch_log_group.tasks]

  provisioner "local-exec" {
    command = <<EOT
      aws ecs run-task \
        --cluster ${var.ecs_cluster_name} \
        --task-definition ${aws_ecs_task_definition.tasks[each.key].arn} \
        --launch-type FARGATE \
        --network-configuration "awsvpcConfiguration={subnets=[${join(",", var.private_subnet_ids)}],securityGroups=[${each.value.security_group}],assignPublicIp=DISABLED}" \
        --region ${var.aws_region}
    EOT
  }
}
