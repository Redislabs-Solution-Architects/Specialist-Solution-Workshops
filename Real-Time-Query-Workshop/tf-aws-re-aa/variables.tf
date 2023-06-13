#### Provider variables
variable "region1" {
    description = "AWS region"
}

variable "region2" {
    description = "AWS region"
}


variable "aws_creds" {
    description = "Access key and Secret key for AWS [Access Keys, Secret Key]"
}

#### Important variables
variable "ssh_key_name1" {
    description = "name of ssh key to be added to instance"
}

variable "ssh_key_name2" {
    description = "name of ssh key to be added to instance"
}

variable "ssh_key_path1" {
    description = "name of ssh key to be added to instance"
}

variable "ssh_key_path2" {
    description = "name of ssh key to be added to instance"
}

variable "owner" {
    description = "owner tag name"
}

#### VPC
variable "base_name1" {
    description = "base name for resources (prefix name)"
    default = "redisuser1-tf"
}

variable "base_name2" {
    description = "base name for resources (prefix name)"
    default = "redisuser2-tf"
}

variable "vpc_cidr1" {
    description = "vpc-cidr1"
    default = "10.0.0.0/16"
}

variable "vpc_cidr2" {
    description = "vpc-cidr2"
    default = "10.1.0.0/16"
}

variable "subnet_cidr_blocks1" {
    type = list(any)
    description = "subnet_cidr_block1"
    default = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
}

variable "subnet_cidr_blocks2" {
    type = list(any)
    description = "subnet_cidr_block2"
    default = ["10.1.1.0/24","10.1.2.0/24","10.1.3.0/24"]
}

variable "subnet_azs1" {
    type = list(any)
    description = "subnet availability zone"
    default = [""]
}

variable "subnet_azs2" {
    type = list(any)
    description = "subnet availability zone"
    default = [""]
}

#### DNS
variable "dns_hosted_zone_id" {
    description = "DNS hosted zone Id"
}

#### Test Instance Variables
variable "test-node-count" {
  description = "number of data nodes"
  default     = 1
}

variable "test_instance_type" {
    description = "instance type to use. Default: t3.micro"
    default = "t3.micro"
}

#### Redis Enterprise Cluster Variables
variable "re_download_url" {
  description = "re download url"
  default     = ""
}

variable "flash_enabled" {
  description = "Redis on Flash cluster"
  default     = false
}

variable "rack_awareness" {
  description = "Rack zone aware cluster"
  default     = false
}


variable "data-node-count" {
  description = "number of data nodes"
  default     = 3
}

variable "ena-support" {
  description = "choose AMIs that have ENA support enabled"
  default     = true
}

variable "re_instance_type" {
    description = "re instance type"
    default     = "t2.xlarge"
}

variable "node-root-size" {
  description = "The size of the root volume"
  default     = "50"
}

#### EBS volume for persistent and ephemeral storage
variable "re-volume-size" {
  description = "The size of the ephemeral and persistent volumes to attach"
  default     = "150"
}

#### Security
variable "open-nets" {
  type        = list(any)
  description = "CIDRs that will have access to everything"
  default     = []
}

variable "allow-public-ssh" {
  description = "Allow SSH to be open to the public - enabled by default"
  default     = "1"
}

variable "internal-rules" {
  description = "Security rules to allow for connectivity within the VPC"
  type        = list(any)
  default = [
    {
      type      = "ingress"
      from_port = "22"
      to_port   = "22"
      protocol  = "tcp"
      comment   = "SSH from VPC"
    },
    {
      type      = "ingress"
      from_port = "1968"
      to_port   = "1968"
      protocol  = "tcp"
      comment   = "Proxy traffic (Internal use)"
    },
    {
      type      = "ingress"
      from_port = "3333"
      to_port   = "3341"
      protocol  = "tcp"
      comment   = "Cluster traffic (Internal use)"
    },
    {
      type      = "ingress"
      from_port = "3343"
      to_port   = "3344"
      protocol  = "tcp"
      comment   = "Cluster traffic (Internal use)"
    },
    {
      type      = "ingress"
      from_port = "36379"
      to_port   = "36380"
      protocol  = "tcp"
      comment   = "Cluster traffic (Internal use)"
    },
    {
      type      = "ingress"
      from_port = "8001"
      to_port   = "8001"
      protocol  = "tcp"
      comment   = "Traffic from application to RS Discovery Service"
    },
    {
      type      = "ingress"
      from_port = "8002"
      to_port   = "8002"
      protocol  = "tcp"
      comment   = "System health monitoring"
    },
    {
      type      = "ingress"
      from_port = "8004"
      to_port   = "8004"
      protocol  = "tcp"
      comment   = "System health monitoring"
    },
    {
      type      = "ingress"
      from_port = "8006"
      to_port   = "8006"
      protocol  = "tcp"
      comment   = "System health monitoring"
    },
    {
      type      = "ingress"
      from_port = "8443"
      to_port   = "8443"
      protocol  = "tcp"
      comment   = "Secure (HTTPS) access to the management web UI"
    },
    {
      type      = "ingress"
      from_port = "8444"
      to_port   = "8444"
      protocol  = "tcp"
      comment   = "nginx <-> cnm_http/cm traffic (Internal use)"
    },
    {
      type      = "ingress"
      from_port = "9080"
      to_port   = "9080"
      protocol  = "tcp"
      comment   = "nginx <-> cnm_http/cm traffic (Internal use)"
    },
    {
      type      = "ingress"
      from_port = "9081"
      to_port   = "9081"
      protocol  = "tcp"
      comment   = "For CRDB management (Internal use)"
    },
    {
      type      = "ingress"
      from_port = "8070"
      to_port   = "8071"
      protocol  = "tcp"
      comment   = "Prometheus metrics exporter"
    },
    {
      type      = "ingress"
      from_port = "9443"
      to_port   = "9443"
      protocol  = "tcp"
      comment   = "REST API traffic, including cluster management and node bootstrap"
    },
    {
      type      = "ingress"
      from_port = "10000"
      to_port   = "19999"
      protocol  = "tcp"
      comment   = "Database traffic - if manually creating db ports pare down"
    },
    {
      type      = "ingress"
      from_port = "20000"
      to_port   = "29999"
      protocol  = "tcp"
      comment   = "Database shards traffic - if manually creating db ports pare down"
    },
    {
      type      = "ingress"
      from_port = "53"
      to_port   = "53"
      protocol  = "udp"
      comment   = "DNS Traffic"
    },
    {
      type      = "ingress"
      from_port = "5353"
      to_port   = "5353"
      protocol  = "udp"
      comment   = "DNS Traffic"
    },
    {
      type      = "ingress"
      from_port = "-1"
      to_port   = "-1"
      protocol  = "icmp"
      comment   = "Ping for connectivity checks between nodes"
    },
    {
      type      = "egress"
      from_port = "-1"
      to_port   = "-1"
      protocol  = "icmp"
      comment   = "Ping for connectivity checks between nodes"
    },
    {
      type      = "egress"
      from_port = "0"
      to_port   = "65535"
      protocol  = "tcp"
      comment   = "Let TCP out to the VPC"
    },
    {
      type      = "egress"
      from_port = "0"
      to_port   = "65535"
      protocol  = "udp"
      comment   = "Let UDP out to the VPC"
    },
    #    {
    #      type      = "ingress"
    #      from_port = "8080"
    #      to_port   = "8080"
    #      protocol  = "tcp"
    #      comment   = "Allow for host check between nodes"
    #    },
  ]
}

variable "external-rules" {
  description = "Security rules to allow for connectivity external to the VPC"
  type        = list(any)
  default = [
    {
      type      = "ingress"
      from_port = "53"
      to_port   = "53"
      protocol  = "udp"
      cidr      = ["0.0.0.0/0"]
    },
    {
      type      = "egress"
      from_port = "0"
      to_port   = "65535"
      protocol  = "tcp"
      cidr      = ["0.0.0.0/0"]
    },
    {
      type      = "egress"
      from_port = "0"
      to_port   = "65535"
      protocol  = "udp"
      cidr      = ["0.0.0.0/0"]
    }
  ]
}

####### Create Cluster Variables
####### Node and DNS outputs used to Create Cluster
variable "dns_fqdn" {
    description = "dns fqdn (cluster name)"
    default = ""
}

variable "re-node-internal-ips" {
    type = list
    description = "re node internal ips"
    default = []
}

variable "re-node-eip-ips" {
    type = list
    description = "re node eip ips"
    default = []
}

variable "re-data-node-eip-public-dns" {
    type = list
    description = "re node eip public dns"
    default = []
}

############# Create RE Cluster Variables

#### Cluster Inputs
#### RE Cluster Username
variable "re_cluster_username" {
    description = "redis enterprise cluster username"
    default     = "admin@admin.com"
}

#### RE Cluster Password
variable "re_cluster_password" {
    description = "redis enterprise cluster password"
    default     = "admin"
}

#### RE License File
variable "license_file" {
    description = "paste RE license file between the variable quotes"
    default     = <<EOF
    paste license file here
    EOF
}

#### RE CRDB DB variable inputs

variable "crdb_db_name" {
    description = "crdb db name"
    default     = "crdb-test1"
}

variable "crdb_port" {
    description = "crdb port"
    default     = 12000
}

variable "crdb_memory_size" {
    description = "memory size in bytes"
    default     = 100000000
}

variable "crdb_replication" {
    description = "replication yes no"
    default     = "True"
}

variable "crdb_aof_policy" {
    description = "aof policy"
    default     = "appendfsync-every-sec"
}

variable "crdb_sharding" {
    description = "sharding yes no"
    default     = "True"
}

variable "crdb_shards_count" {
    description = "how many master shards"
    default     = 1
}
