resource "aws_vpc" "vpc" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_vpc_dhcp_options" "dhcp_opts" {
  domain_name         = "${var.region}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_vpc_dhcp_options_association" "dhcp_opts_assoc" {
  vpc_id          = aws_vpc.vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp_opts.id
}

resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route = []

  tags = {
    Name = "default-172-31-0-0-16"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "default for vpc ${var.vpc_name}"
  }
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.vpc.default_network_acl_id

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
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
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_eip" "natgw_eip" {
  domain = "vpc"
  tags = {
    Name = "pub-usw2-az1-172-31-0-0-22-natgw"
  }
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natgw_eip.id
  subnet_id     = module.pub-usw2-az1-172-31-0-0-22.subnet_id

  connectivity_type = "public"

  tags = {
    Name = "pub-usw2-az1-172-31-0-0-22-natgw"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.s3"

  tags = {
    Name = "${var.vpc_name}-s3-gateway"
  }
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.dynamodb"

  tags = {
    Name = "${var.vpc_name}-dynamodb-gateway"
  }
}

module "pub-usw2-az1-172-31-0-0-22" {
  source = "./public_subnet"

  vpc_id = aws_vpc.vpc.id
  igw_id = aws_internet_gateway.igw.id

  az_id      = "usw2-az1"
  cidr_block = "172.31.0.0/22"
  cidr_id    = "172-31-0-0-22"
}

module "pub-usw2-az2-172-31-4-0-22" {
  source = "./public_subnet"

  vpc_id = aws_vpc.vpc.id
  igw_id = aws_internet_gateway.igw.id

  az_id      = "usw2-az2"
  cidr_block = "172.31.4.0/22"
  cidr_id    = "172-31-4-0-22"
}

// 172.31.8.0/22 for usw2-az3

// 172.31.12.0/22 for usw2-az4

module "prv-usw2-az1-172-31-16-0-20" {
  source = "./private_subnet"

  vpc_id                    = aws_vpc.vpc.id
  natgw_id                  = aws_nat_gateway.natgw.id
  s3_gateway_endpoint       = aws_vpc_endpoint.s3.arn
  dynamodb_gateway_endpoint = aws_vpc_endpoint.dynamodb.arn

  az_id      = "usw2-az1"
  cidr_block = "172.31.16.0/20"
  cidr_id    = "172-31-16-0-20"
}

module "prv-usw2-az2-172-31-32-0-20" {
  source = "./private_subnet"

  vpc_id                    = aws_vpc.vpc.id
  natgw_id                  = aws_nat_gateway.natgw.id
  s3_gateway_endpoint       = aws_vpc_endpoint.s3.arn
  dynamodb_gateway_endpoint = aws_vpc_endpoint.dynamodb.arn

  az_id      = "usw2-az2"
  cidr_block = "172.31.32.0/20"
  cidr_id    = "172-31-32-0-20"
}

// 172.31.48.0/22 for usw2-az3

// 172.31.64.0/20 for usw2-az4
