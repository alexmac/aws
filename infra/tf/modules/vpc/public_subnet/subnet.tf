locals {
  cidr_kebab    = replace(var.cidr_block, "/[./]/", "-")
  cidr_first_ip = replace(replace(var.cidr_block, "/[.]/", "-"), "//.*/", "")
}

resource "aws_subnet" "subnet" {
  tags = {
    Name = "pub-${var.az_id}-${local.cidr_kebab}"
  }
  vpc_id                          = var.vpc_id
  cidr_block                      = var.cidr_block
  availability_zone_id            = var.az_id
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = false
}

resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id
  tags = {
    Name = "pub-${var.az_id}-${local.cidr_kebab}"
  }
}

resource "aws_route" "route" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_network_acl" "main" {
  vpc_id = var.vpc_id

  subnet_ids = [aws_subnet.subnet.id]

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 1
    action     = "allow"
    cidr_block = var.vpc_cidr_block
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 2
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 3
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 3389
    to_port    = 3389
  }

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "pub-${var.az_id}-${local.cidr_kebab}"
  }
}

output "subnet_id" {
  value       = aws_subnet.subnet.id
  description = "The ID of the VPC Subnet"
}
