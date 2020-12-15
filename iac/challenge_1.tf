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
  private_subnet_count = length(data.aws_availability_zones.available.names)
  public_subnet_count = length(data.aws_availability_zones.available.names)
}

resource "aws_vpc" "default" {
  cidr_block = var.cidr_block
}

resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_vpc.default.id
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_subnet" "private" {
  count             = local.private_subnet_count
  vpc_id            = aws_vpc.default.id
  cidr_block = cidrsubnet(
    signum(length(var.cidr_block)) == 1 ? var.cidr_block : aws_vpc.default.cidr_block,
    ceil(log(local.private_subnet_count * 2, 2)),
    count.index
  )
}


resource "aws_subnet" "public" {
  count             = local.public_subnet_count
  vpc_id            = aws_vpc.default.id
  cidr_block = cidrsubnet(
    signum(length(var.cidr_block)) == 1 ? var.cidr_block : aws_vpc.default.cidr_block,
    ceil(log(local.public_subnet_count * 2, 2)),
    count.index
  )
}

############### Private Route Table##############
resource "aws_route_table" "private" {
  count  = local.subnet_count
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table_association" "private" {
  count          = local.subnet_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}
#########################################################################

############### Public Route Table##############
#
resource "aws_route_table" "public" {
  count  = local.subnet_count
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table_association" "public" {
  count          = local.subnet_count
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
}
#########################################################################

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


resource "aws_eip" "nat_eip" {
  vpc      = true
}

resource "aws_nat_gateway" "gateway" {
  count = length(data.aws_availability_zones.available.names)
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public.*.id, count.index)
}



resource "aws_security_group" "custom_sg" {
  name        = "custom security group"
  vpc_id      = aws_vpc.default.id

  ingress {
    from_port   = 433
    to_port     = 433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
