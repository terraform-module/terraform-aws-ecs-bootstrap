resource "aws_service_discovery_service" "this" {
  count = var.create && try(var.sds.create, false) ? 1 : 0

  name        = var.name
  description = format("Service Discovery Service for --%s--.", var.name)
  tags        = var.tags

  dns_config {
    namespace_id = var.sds.namespace_id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = try(var.sds.routing_policy, local.defaults_sds.routing_policy)
  }

  health_check_custom_config {
    failure_threshold = try(var.sds.failure_threshold, local.defaults_sds.failure_threshold)
  }
}
