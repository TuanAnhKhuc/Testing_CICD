##############################################
# Service Discovery outputs - outputs.tf     #
##############################################

output "namespace_id" {
  description = "ID of the CloudMap namespace"
  value       = aws_service_discovery_private_dns_namespace.this.id
}

output "service_arns" {
  description = "Map of service names to their CloudMap ARNs"
  value       = { for svc in aws_service_discovery_service.services : svc.name => svc.arn }
}
