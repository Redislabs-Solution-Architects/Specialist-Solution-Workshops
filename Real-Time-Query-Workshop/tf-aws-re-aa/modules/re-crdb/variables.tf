#### Required Variables

####### Create Cluster Variables
####### Node and DNS outputs used to Create Cluster
#### created during node module and used as outputs (no input required)
variable "dns_fqdn1" {
    description = "Cluster 1 FQDN"
    default = ""
}

variable "dns_fqdn2" {
    description = "Cluster 2 FQDN"
    default = ""
}

############# Create RE Cluster Variables

#### Cluster Inputs
#### RE Cluster Username
variable "re_cluster_username" {
    description = "redis enterprise cluster username"
}

#### RE Cluster Password
variable "re_cluster_password" {
    description = "redis enterprise cluster password"
}

#### RE CRDB DB variable inputs
variable "crdb_db_name" {
    description = "crdb db name"
}

variable "crdb_port" {
    description = "crdb port"
}

variable "crdb_memory_size" {
    description = "crdb memory size in bytes"
}

variable "crdb_replication" {
    description = "replication yes no"
}

variable "crdb_aof_policy" {
    description = "aof policy"
}

variable "crdb_sharding" {
    description = "sharding yes no"
}

variable "crdb_shards_count" {
    description = "how many master shards"
}

variable "execution" {
    description = "current execution loop count"
}