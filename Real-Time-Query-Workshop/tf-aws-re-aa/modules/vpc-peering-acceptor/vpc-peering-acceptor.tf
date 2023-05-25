#### VPC Accepter, takes vpc peering connection id and auto accepts
#### this is using the provider of the accepter account or region (ie. cluster 2)

### Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = var.vpc_peering_connection_id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}