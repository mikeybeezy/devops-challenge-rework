

terraform {
  required_version = ">= 0.13.0"
  required_providers {
    aws = ">= 2.7.0"
  }
}


data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}


locals {
  subnet_count = length(data.aws_availability_zones.available.names)
  region       = "eu-west-1"
}

resource "aws_vpc" "default" {
  cidr_block = "10.10.10.0/18"
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_subnet" "private" {
  count             = local.private_subnet_count
  vpc_id            = aws_vpc.default.id
  cidr_block = cidrsubnet(
    signum(length(...)) == 1 ? ... : aws_vpc.default.cidr_block
    ceil(log(local.private_subnet_count * 2, 2)),
    count.index
  )
}

resource "aws_route_table" "private" {
  count  = local.subnet_count
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table_association" "private" {
  count          = local.subnet_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.default.id
  subnet_ids = aws_subnet.private.*.id

  egress {
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
  }

  ingress {
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
  }
}
