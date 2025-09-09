##############################################
# Security Groups outputs - outputs.tf       #
##############################################

output "rds_sg_id" { value = aws_security_group.rds.id }
output "alb_sg_id" { value = aws_security_group.alb.id }
output "ecs_sg_id" { value = aws_security_group.ecs.id }
output "backend_ecs_sg_id" { value = aws_security_group.backend_ecs.id }
