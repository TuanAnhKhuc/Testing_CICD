resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.name_prefix}-ecs-task-execution"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution.arn
}

data "aws_iam_policy_document" "secrets_read" {
  count = length(var.secrets_arns) > 0 ? 1 : 0
  statement {
    sid     = "SecretsManagerRead"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = var.secrets_arns
  }
}

resource "aws_iam_role_policy" "secrets_read" {
  count  = length(var.secrets_arns) > 0 ? 1 : 0
  name   = "secrets-read"
  role   = aws_iam_role.ecs_task_execution.id
  policy = data.aws_iam_policy_document.secrets_read[0].json
}
