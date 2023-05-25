variable "crdbs" {
  default = ["crdb1","crdb2","crdb3","crdb4","crdb5","crdb6","crdb7","crdb8","crdb9","crdb10"]
}

############## RE Cluster CRDB databases
#### Ansible Playbook runs locally to create the CRDB db between cluster A and B
module "create-crdbs" {
  count = length(var.crdbs)
  source               = "./modules/re-crdb"
  execution = count.index
  providers = {
      aws = aws.a
    }
  re_cluster_username  = var.re_cluster_username
  re_cluster_password  = var.re_cluster_password
  dns_fqdn1            = module.dns1.dns-ns-record-name
  dns_fqdn2            = module.dns2.dns-ns-record-name #getting cluster2 name from other module
  #### crdb db inputs
  #crdb_db_name         = var.crdb_db_name
  #crdb_port            = var.crdb_port
  crdb_db_name         = var.crdbs[count.index]
  crdb_port            = var.crdb_port+count.index
  crdb_memory_size     = var.crdb_memory_size
  crdb_replication     = var.crdb_replication
  crdb_aof_policy      = var.crdb_aof_policy
  crdb_sharding        = var.crdb_sharding
  crdb_shards_count    = var.crdb_shards_count

  depends_on           = [module.vpc1,
                          module.vpc2,
                          module.nodes1,
                          module.nodes2, 
                          module.dns1,
                          module.dns2, 
                          module.create-cluster1, 
                          module.create-cluster2]
}

#### CRDB Outputs
output "crdb_endpoint_cluster1" {
  value = module.create-crdbs[*].crdb_endpoint_cluster1
}

output "crdb_endpoint_cluster2" {
  value = module.create-crdbs[*].crdb_endpoint_cluster2
}

output "crdb_cluster1_redis_cli_cmd" {
  value = module.create-crdbs[*].crdb_cluster1_redis_cli_cmd
}

output "crdb_cluster2_redis_cli_cmd" {
  value = module.create-crdbs[*].crdb_cluster2_redis_cli_cmd
}
