#### Outputs

output "crdb_endpoint_cluster1" {
  value = format("redis-%s.%s", var.crdb_port,var.dns_fqdn1)
}

output "crdb_endpoint_cluster2" {
  value = format("redis-%s.%s", var.crdb_port,var.dns_fqdn2)
}

output "crdb_cluster1_redis_cli_cmd" {
  value = format("redis-cli -h redis-%s.%s -p %s", var.crdb_port,var.dns_fqdn1,var.crdb_port)
}

output "crdb_cluster2_redis_cli_cmd" {
  value = format("redis-cli -h redis-%s.%s -p %s", var.crdb_port,var.dns_fqdn2,var.crdb_port)
}