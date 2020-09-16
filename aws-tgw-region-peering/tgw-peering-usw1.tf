
provider "aws" {
  alias   = "tgw-usw1"
}

data "aws_caller_identity" "tgw-usw1" {
  provider = aws.tgw-usw1
}

data "aws_ec2_transit_gateway" "tgw-usw1" {
  provider = aws.tgw-usw1
  filter {
    name   = "tag:Name"
    values = ["${var.tgw-name}"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
  #optional filter if you want to have an extra layer of control
  filter {
    name   = "owner-id"
    values = [data.aws_caller_identity.tgw-usw1.account_id]
  }
}

data "aws_ec2_transit_gateway_route_table" "rtb-usw1" {
  provider = aws.tgw-usw1
  filter {
    name   = "tag:Name"
    values = ["${var.tgw-name}-transit-rtb"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw" {
  provider = aws.tgw-usw1

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.tgw.id
  tags = merge(local.tags, map("Side","Accept")) 
}

resource "aws_ec2_transit_gateway_route_table_association" "rtb-attach-usw1" {
  provider = aws.tgw-usw1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.rtb-usw1.id
}

resource "aws_ec2_transit_gateway_route" "routes_to_use1" {
  for_each = toset(var.routes_to_use1)
  provider = aws.tgw-usw1
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.tgw.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.rtb-usw1.id

  #useful for changes outside of terraform control https://www.terraform.io/docs/configuration/resources.html
  lifecycle {
    ignore_changes = all
  }
}
