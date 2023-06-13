##### Create CRDB database from cluster 1 with participating cluster (cluster 2)
##### use crdb input values to define the params of the crdb. 


##### Generate ansible inventory.ini for any number of nodes
resource "local_file" "crdb_tpl" {
    content  = templatefile("${path.module}/crdbs/crdb.tpl", {
        # cluster info
        cluster1     = var.dns_fqdn1
        cluster2     = var.dns_fqdn2
        username1    = var.re_cluster_username
        pwd1         = var.re_cluster_password
        username2    = var.re_cluster_username
        pwd2         = var.re_cluster_password

        # db info
        db_name      = var.crdb_db_name
        port         = var.crdb_port
        memory_size  = var.crdb_memory_size
        replication  = var.crdb_replication
        aof_policy   = var.crdb_aof_policy
        sharding     = var.crdb_sharding
        shards_count = var.crdb_shards_count
    })
    filename = "${path.module}/crdbs/crdb${var.execution}.py"
}

#### Sleeper, just to make sure nodes module is complete and everything is installed
resource "time_sleep" "wait_30_seconds_crdb" {
  create_duration = "30s"
}

#Run ansible-playbook to create crdb from python script (REST API)
resource "null_resource" "ansible_create_crdb_restapi" {
  provisioner "local-exec" {
    command = "python3 ${path.module}/crdbs/crdb${var.execution}.py"
    }

    depends_on = [
      local_file.crdb_tpl,
      time_sleep.wait_30_seconds_crdb
    ]
}