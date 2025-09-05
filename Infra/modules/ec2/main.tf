data "aws_region" "current" {}

# Latest Amazon Linux 2023 AMI via SSM Parameter
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

resource "aws_iam_role" "ec2" {
  name               = "${var.tags["Project"]}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "secrets_read" {
  name = "allow-secretsmanager-get"
  role = aws_iam_role.ec2.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["secretsmanager:GetSecretValue"],
        Resource = var.backend_db_secret_arn != "" ? var.backend_db_secret_arn : "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.tags["Project"]}-ec2-profile"
  role = aws_iam_role.ec2.name
}

locals {
  user_data = <<-EOT
    #!/bin/bash
    set -euxo pipefail
    dnf update -y
    dnf install -y docker awscli jq
    systemctl enable --now docker

    # pull and run containers
    DB_CONN=""
    if [ -n "${var.backend_db_secret_arn}" ]; then
      DB_CONN=$(aws secretsmanager get-secret-value \
        --secret-id ${var.backend_db_secret_arn} \
        --query SecretString --output text | jq -r '.ConnectionString') || true
    fi

    docker pull ${var.frontend_image} || true
    docker pull ${var.backend_image} || true

    # Run frontend (port 80)
    docker run -d --restart unless-stopped --name frontend -p 80:80 ${var.frontend_image}

    # Run backend (port 8080)
    docker run -d --restart unless-stopped --name backend -p 8080:8080 \
      -e ConnectionStrings__db="$DB_CONN" \
      ${var.backend_image}
  EOT
}

resource "aws_instance" "this" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.sg_id]
  iam_instance_profile        = aws_iam_instance_profile.this.name
  associate_public_ip_address = false
  user_data_base64            = base64encode(local.user_data)
  tags                        = merge(var.tags, { Name = "${var.tags["Project"]}-app-ec2" })
}

# Attach the instance's private IP to target groups (target_type = "ip")
resource "aws_lb_target_group_attachment" "frontend" {
  target_group_arn = var.frontend_target_group_arn
  target_id        = aws_instance.this.private_ip
  port             = 80
}

resource "aws_lb_target_group_attachment" "backend" {
  target_group_arn = var.backend_target_group_arn
  target_id        = aws_instance.this.private_ip
  port             = 8080
}

output "instance_id" {
  value = aws_instance.this.id
}

output "private_ip" {
  value = aws_instance.this.private_ip
}

