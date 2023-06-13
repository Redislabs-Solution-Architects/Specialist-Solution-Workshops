########## Active Active Db Redis Enterprise Clusters between 2 regions (Cluster 1) #####
#### Modules to create the following:
#### Brand new VPC in region A
#### VPC peering requestor from region A to VPC in region B
#### VPC peering acceptor from region B to region A
#### Route table VPC peering id association for VPC A
#### Cluster A, RE nodes and install RE software (ubuntu)
#### VPC A, Test node with Redis and Memtier
#### Cluster A, DNS (NS and A records for RE nodes)
#### Cluster A, Create and Join RE cluster
#### Create CRDB DB between Cluster A & Cluster B
#### Run Memtier benchmark data load and benchmark cmd from tester node in VPC A to Cluster A


########### VPC Module
#### create a brand new VPC, use its outputs in future modules
#### If you already have an existing VPC, comment out and
#### enter your VPC params in the future modules
module "vpc1" {
    source             = "./modules/vpc"
    providers = {
      aws = aws.a
    }
    aws_creds          = var.aws_creds
    owner              = var.owner
    region             = var.region1
    base_name          = var.base_name1
    vpc_cidr           = var.vpc_cidr1
    subnet_cidr_blocks = var.subnet_cidr_blocks1
    subnet_azs         = var.subnet_azs1
}

### VPC outputs 
### Outputs from VPC outputs.tf, 
### must output here to use in future modules)
output "subnet-ids1" {
  value = module.vpc1.subnet-ids
}

output "vpc-id1" {
  value = module.vpc1.vpc-id
}

output "vpc_name1" {
  description = "get the VPC Name tag"
  value = module.vpc1.vpc-name
}

output "route-table-id1" {
  description = "route table id"
  value = module.vpc1.route-table-id
}

######
#### VPC Peering Modules
#### VPC peering is broken into 2 modules because you need to 
#### request from region A (provider A), and accept from region B (provider B)
#### Final step is to do a route table association to the VPC peering ID

#### VPC peering requestor from region A (VPC A) to region B (VPC B)
module "vpc-peering-requestor" {
    source             = "./modules/vpc-peering-requestor"
    providers = {
      aws = aws.a
    }
    peer_region        = var.region2
    main_vpc_id        = module.vpc1.vpc-id
    peer_vpc_id        = module.vpc2.vpc-id
    vpc_name1          = module.vpc1.vpc-name
    vpc_name2          = module.vpc2.vpc-name
    owner              = var.owner

    depends_on = [
      module.vpc1, module.vpc2
    ]
}

#### output the vpc peering ID to use in acceptor module
output "vpc_peering_connection_id" {
  description = "VPC peering connection ID"
  value = module.vpc-peering-requestor.vpc_peering_connection_id
}

#### VPC peering acceptor, accept from region B (VPC B) to region A (VPC A)
module "vpc-peering-acceptor" {
    source             = "./modules/vpc-peering-acceptor"
    providers = {
      aws = aws.b
    }
    vpc_peering_connection_id = module.vpc-peering-requestor.vpc_peering_connection_id

    depends_on = [
      module.vpc1, module.vpc2, module.vpc-peering-requestor
    ]
}

#### Route table association in reigon A (VPC A) for vpc peering id to VPC CIDR in Region B
module "vpc-peering-routetable1" {
    source             = "./modules/vpc-peering-routetable"
    providers = {
      aws = aws.a
    }
    peer_vpc_id               = module.vpc2.vpc-id
    main_vpc_route_table_id   = module.vpc1.route-table-id
    vpc_peering_connection_id = module.vpc-peering-requestor.vpc_peering_connection_id
    peer_vpc_cidr      = var.vpc_cidr2

    depends_on = [
      module.vpc1, 
      module.vpc2, 
      module.vpc-peering-requestor,
      module.vpc-peering-acceptor
    ]
}

########### Node Module
#### Create RE and Test nodes
#### Ansible playbooks configure and install RE software on nodes
#### Ansible playbooks configure Test node with Redis and Memtier
module "nodes1" {
    source             = "./modules/nodes"
    providers = {
      aws = aws.a
    }
    owner              = var.owner
    region             = var.region1
    vpc_cidr           = var.vpc_cidr1
    subnet_azs         = var.subnet_azs1
    ssh_key_name       = var.ssh_key_name1
    ssh_key_path       = var.ssh_key_path1
    test_instance_type = var.test_instance_type
    test-node-count    = var.test-node-count
    re_download_url    = var.re_download_url
    data-node-count    = var.data-node-count
    re_instance_type   = var.re_instance_type
    re-volume-size     = var.re-volume-size
    allow-public-ssh   = var.allow-public-ssh
    open-nets          = var.open-nets
    ### vars pulled from previous modules
    ## from vpc module outputs 
    vpc_name           = module.vpc1.vpc-name
    vpc_subnets_ids    = module.vpc1.subnet-ids
    vpc_id             = module.vpc1.vpc-id
}

#### Node Outputs to use in future modules
output "re-data-node-eips1" {
  value = module.nodes1.re-data-node-eips
}

output "re-data-node-internal-ips1" {
  value = module.nodes1.re-data-node-internal-ips
}

output "re-data-node-eip-public-dns1" {
  value = module.nodes1.re-data-node-eip-public-dns
}

########### DNS Module
#### Create DNS (NS record, A records for each RE node and its eip)
#### Currently using existing dns hosted zone
module "dns1" {
    source             = "./modules/dns"
    providers = {
      aws = aws.a
    }
    dns_hosted_zone_id = var.dns_hosted_zone_id
    data-node-count    = var.data-node-count
    ### vars pulled from previous modules
    vpc_name           = module.vpc1.vpc-name
    re-data-node-eips  = module.nodes1.re-data-node-eips
}

#### dns FQDN output used in future modules
output "dns-ns-record-name1" {
  value = module.dns1.dns-ns-record-name
}

############## RE Cluster
#### Ansible Playbook runs locally to create the cluster A
module "create-cluster1" {
  source               = "./modules/re-cluster"
  providers = {
      aws = aws.a
    }
  ssh_key_path         = var.ssh_key_path1
  region               = var.region1
  re_cluster_username  = var.re_cluster_username
  re_cluster_password  = var.re_cluster_password
  flash_enabled        = var.flash_enabled
  rack_awareness       = var.rack_awareness
  ### vars pulled from previous modules
  vpc_name             = module.vpc1.vpc-name
  re-node-internal-ips = module.nodes1.re-data-node-internal-ips
  re-node-eip-ips      = module.nodes1.re-data-node-eips
  re-data-node-eip-public-dns   = module.nodes1.re-data-node-eip-public-dns
  dns_fqdn             = module.dns1.dns-ns-record-name
  
  depends_on           = [module.vpc1, module.nodes1, module.dns1]
}

#### Cluster Outputs
output "re-cluster-url" {
  value = module.create-cluster1.re-cluster-url
}

output "re-cluster-username" {
  value = module.create-cluster1.re-cluster-username
}

output "re-cluster-password" {
  value = module.create-cluster1.re-cluster-password
}

############## RE Cluster CRDB databases
#### Ansible Playbook runs locally to create the CRDB db between cluster A and B
#module "create-crdbs" {
#  source               = "./modules/re-crdb"
#  providers = {
#      aws = aws.a
#    }
  #re_cluster_username  = var.re_cluster_username
  #re_cluster_password  = var.re_cluster_password
  #dns_fqdn1            = module.dns1.dns-ns-record-name
  #dns_fqdn2            = module.dns2.dns-ns-record-name #getting cluster2 name from other module
  #### crdb db inputs
  #crdb_db_name         = var.crdb_db_name
  #crdb_port            = var.crdb_port
  #crdb_memory_size     = var.crdb_memory_size
  #crdb_replication     = var.crdb_replication
  #crdb_aof_policy      = var.crdb_aof_policy
  #crdb_sharding        = var.crdb_sharding
  #crdb_shards_count    = var.crdb_shards_count

#  depends_on           = [module.vpc1,
#                          module.vpc2,
#                          module.nodes1,
#                          module.nodes2, 
#                          module.dns1,
#                          module.dns2, 
#                          module.create-cluster1, 
#                          module.create-cluster2]
#}

#### CRDB Outputs
#output "crdb_endpoint_cluster1" {
#  value = module.create-crdbs.crdb_endpoint_cluster1
#}

#output "crdb_endpoint_cluster2" {
#  value = module.create-crdbs.crdb_endpoint_cluster2
#}

#output "crdb_cluster1_redis_cli_cmd" {
#  value = module.create-crdbs.crdb_cluster1_redis_cli_cmd
#}

#output "crdb_cluster2_redis_cli_cmd" {
#  value = module.create-crdbs.crdb_cluster2_redis_cli_cmd
#}
