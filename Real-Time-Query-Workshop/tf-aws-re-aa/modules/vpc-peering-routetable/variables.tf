#### Required Variables

variable "peer_vpc_id" {
  description = "The ID of the peer VPC"
  default = ""
}

variable "peer_vpc_cidr" {
  description = "The VPC CIDR of the peer VPC"
  default = ""
}

variable "main_vpc_route_table_id" {
  description = "The main vpc route table id"
  default = ""
}

variable "vpc_peering_connection_id" {
  description = "vpc peering connection id"
  default = ""
}