resource "aws_subnet" "subnet" {
  tags = {
    Name = "prv-${var.az_id}-${var.cidr_id}"
  }
  vpc_id                          = var.vpc_id
  cidr_block                      = var.cidr_block
  availability_zone_id            = var.az_id
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
}

resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id
  tags = {
    Name = "prv-${var.az_id}-${var.cidr_id}"
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3_gateway_assoc" {
  route_table_id  = aws_route_table.route_table.id
  vpc_endpoint_id = split("vpc-endpoint/", var.s3_gateway_endpoint)[1]
}

resource "aws_vpc_endpoint_route_table_association" "dynamodb_gateway_assoc" {
  route_table_id  = aws_route_table.route_table.id
  vpc_endpoint_id = split("vpc-endpoint/", var.dynamodb_gateway_endpoint)[1]
}

resource "aws_route" "route" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.natgw_id
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
    cidr_block = "172.31.0.0/16"
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
    Name = "prv-${var.az_id}-${var.cidr_id}"
  }
}

output "subnet_id" {
  value       = aws_subnet.subnet.id
  description = "The ID of the VPC Subnet"
}
