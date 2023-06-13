#### VPC peer requestor, requires getting aws account id from provider of requester
#### uses the peer and requestor VPC ID and creates request, that will be used in accepter.
### using cluster 1 as the requester (ie. cluster 1)

# get the aws account id for the provider
data "aws_caller_identity" "current1" {}

output "account_id" {
  value = data.aws_caller_identity.current1.account_id
}

# Requester's side of the connection.
resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = var.main_vpc_id
  peer_vpc_id   = var.peer_vpc_id
  peer_owner_id = data.aws_caller_identity.current1.account_id
  peer_region   = var.peer_region
  auto_accept   = false

  tags = {
    Side  = "Requester"
    Name  = format("vpc-peer-%s-and-%s", var.vpc_name1, var.vpc_name2),
    Owner = var.owner
  }
  timeouts {
    create = "10m"
    delete = "10m"
  }
}

output "vpc_peering_connection_id" {
  value = aws_vpc_peering_connection.peer.id
}