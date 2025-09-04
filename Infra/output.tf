output "alb_dns" {
  value = module.alb.alb_dns
}

output "ecs_cluster" {
  value = module.ecs.cluster_name
}

output "frontend_service_name" {
  value = module.ecs.frontend_service_name
}

output "backend_service_name" {
  value = module.ecs.backend_service_name
}
