
provider "aws" {
  alias   = "tgw-use1"
}

data "aws_caller_identity" "tgw-use1" {
  provider = aws.tgw-use1
}

data "aws_ec2_transit_gateway" "tgw-use1" {
  provider = aws.tgw-use1
  filter {
    name   = "tag:Name"
    values = ["${var.tgw-name}-tgw"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "owner-id"
    values = [data.aws_caller_identity.tgw-use1.account_id]
  }
}

data "aws_ec2_transit_gateway_route_table" "rtb-use1" {
  provider = aws.tgw-use1
  filter {
    name   = "tag:Name"
    values = ["${var.tgw-name}-tgw-transit"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_ec2_transit_gateway_peering_attachment" "tgw" {
  provider = aws.tgw-use1

  peer_account_id         = data.aws_caller_identity.tgw-use1.account_id
  peer_region             = local.usw1
  peer_transit_gateway_id = data.aws_ec2_transit_gateway.tgw-usw1.id
  transit_gateway_id      = data.aws_ec2_transit_gateway.tgw-use1.id

  tags = merge(local.tags, map("Side","Request"))
}

resource "aws_ec2_transit_gateway_route_table_association" "rtb-attach-use1" {
  provider = aws.tgw-use1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.tgw.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.rtb-use1.id
}

resource "aws_ec2_transit_gateway_route" "routes_to_usw1" {
  for_each = toset(var.routes_to_usw1)
  provider = aws.tgw-use1
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.tgw.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.rtb-use1.id

  #useful for changes outside of terraform control https://www.terraform.io/docs/configuration/resources.html
  lifecycle {
    ignore_changes = all
  }
}
