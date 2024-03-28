locals {
  cidr_block    = "${var.class_b_prefix}.0.0/16"
  cidr_kebab    = replace(local.cidr_block, "/[./]/", "-")
  cidr_first_ip = replace(replace(local.cidr_block, "/[.]/", "-"), "//.*/", "")
  region_map    = { "us-west-2" = "usw2" }
  az1           = "${local.region_map[var.region]}-az1"
  az2           = "${local.region_map[var.region]}-az2"
}

resource "aws_vpc" "vpc" {
  cidr_block           = local.cidr_block
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
    Name = "default-${local.cidr_kebab}"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  ingress = []

  egress = []

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
    protocol   = "tcp"
    rule_no    = 1
    action     = "allow"
    cidr_block = local.cidr_block
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
    Name = "pub-${local.az1}-${local.cidr_first_ip}-22-natgw"
  }
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natgw_eip.id
  subnet_id     = module.pub-az1-subnet-1.subnet_id

  connectivity_type = "public"

  tags = {
    Name = "pub-${local.az1}-${local.cidr_first_ip}-22-natgw"
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

module "pub-az1-subnet-1" {
  source = "./public_subnet"

  vpc_id = aws_vpc.vpc.id
  igw_id = aws_internet_gateway.igw.id

  az_id          = local.az1
  vpc_cidr_block = local.cidr_block
  cidr_block     = "${var.class_b_prefix}.0.0/22"
}

module "pub-az2-subnet-1" {
  source = "./public_subnet"

  vpc_id = aws_vpc.vpc.id
  igw_id = aws_internet_gateway.igw.id

  az_id          = local.az2
  vpc_cidr_block = local.cidr_block
  cidr_block     = "${var.class_b_prefix}.4.0/22"
}

// ${var.class_b_prefix}.8.0/22 for usw2-az3

// ${var.class_b_prefix}.12.0/22 for usw2-az4

module "prv-az1-subnet-1" {
  source = "./private_subnet"

  vpc_id                    = aws_vpc.vpc.id
  natgw_id                  = aws_nat_gateway.natgw.id
  s3_gateway_endpoint       = aws_vpc_endpoint.s3.arn
  dynamodb_gateway_endpoint = aws_vpc_endpoint.dynamodb.arn

  az_id          = local.az1
  vpc_cidr_block = local.cidr_block
  cidr_block     = "${var.class_b_prefix}.16.0/20"
}

module "prv-az2-subnet-1" {
  source = "./private_subnet"

  vpc_id                    = aws_vpc.vpc.id
  natgw_id                  = aws_nat_gateway.natgw.id
  s3_gateway_endpoint       = aws_vpc_endpoint.s3.arn
  dynamodb_gateway_endpoint = aws_vpc_endpoint.dynamodb.arn

  az_id          = local.az2
  vpc_cidr_block = local.cidr_block
  cidr_block     = "${var.class_b_prefix}.32.0/20"
}

// ${var.class_b_prefix}.48.0/20 for usw2-az3

// ${var.class_b_prefix}.64.0/20 for usw2-az4
