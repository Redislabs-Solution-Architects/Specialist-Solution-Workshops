
#### Add AWS route table association for both VPCs (cluster1 and cluster2)
#### Required for VPC peering to work properly

#### Sleeper, after cluster is created sleep for 30s 
#### to make sure its up and running before attempting to add the license file
resource "time_sleep" "wait_30_seconds_vpc_peering" {
  create_duration = "30s"
}

## Add a AWS Route to AWS VPC Route Tables

# Declare the data source
data "aws_vpc_peering_connection" "peer-active" {
  peer_vpc_id = var.peer_vpc_id
  status      = "active"
  depends_on = [time_sleep.wait_30_seconds_vpc_peering]
}

# Create a route
resource "aws_route" "vpc-route-table-association" {
  route_table_id            = var.main_vpc_route_table_id
  destination_cidr_block    = var.peer_vpc_cidr
  vpc_peering_connection_id = var.vpc_peering_connection_id

  depends_on = [
    data.aws_vpc_peering_connection.peer-active
  ]
}