##############################################
# Service Discovery (CloudMap) - main.tf     #
##############################################

resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = "${var.environment}.local"
  description = "Service discovery namespace for ECS"
  vpc         = var.vpc_id
  tags        = { Name = "${var.environment}-cloudmap-namespace" }
}

resource "aws_service_discovery_service" "services" {
  for_each = { for svc in var.services : svc.name => svc }

  name = each.value.name
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id
    dns_records {
      type = each.value.dns_record_type
      ttl  = each.value.dns_ttl
    }
    routing_policy = each.value.routing_policy
  }
  tags = merge(
    { Name = "${var.environment}-${each.value.name}-discovery" },
    each.value.tags
  )
}
