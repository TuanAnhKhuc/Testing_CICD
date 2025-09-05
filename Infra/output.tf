output "alb_dns" {
  value = module.alb.alb_dns
}

output "ecs_cluster" {
  value = length(module.ecs) > 0 ? module.ecs[0].cluster_name : null
}

output "frontend_service_name" {
  value = length(module.ecs) > 0 ? module.ecs[0].frontend_service_name : null
}

output "backend_service_name" {
  value = length(module.ecs) > 0 ? module.ecs[0].backend_service_name : null
}

output "frontend_tg_arn" {
  value = module.alb.frontend_tg_arn
}

output "backend_tg_arn" {
  value = module.alb.backend_tg_arn
}

output "ec2_instance_id" {
  value = length(module.ec2) > 0 ? module.ec2[0].instance_id : null
}

output "ec2_private_ip" {
  value = length(module.ec2) > 0 ? module.ec2[0].private_ip : null
}
