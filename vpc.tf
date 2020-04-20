resource "aws_vpc" "bastion" {
  cidr_block                       = "172.31.0.0/16"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  instance_tenancy                 = "default"
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name  = "${var.project}-${var.env}"
    Group = var.project
  }
}

resource "aws_internet_gateway" "bastion" {
  vpc_id = aws_vpc.bastion.id

  tags = {
    Name  = "${var.project}-${var.env}"
    Group = var.project
  }
}

resource "aws_route_table" "bastion" {
  vpc_id = aws_vpc.bastion.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bastion.id
  }

  route {
    cidr_block                = "172.32.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.bastion_dev.id
  }

  tags = {
    Name  = "${var.project}-${var.env}"
    Group = var.project
  }
}

resource "aws_vpc_peering_connection" "bastion_dev" {
  peer_vpc_id = aws_vpc.bastion.id
  vpc_id      = data.terraform_remote_state.dev.outputs.vpc_dev_id
  auto_accept = true
  tags = {
    Name = "${var.project}-${var.env}-dev-peering"
  }
}

resource "aws_subnet" "bastion" {
  vpc_id                  = aws_vpc.bastion.id
  cidr_block              = "172.31.0.0/20"
  availability_zone       = "${var.region}c"
  map_public_ip_on_launch = true

  tags = {
    Name  = "${var.project}-${var.env}"
    Group = var.project
  }
}

resource "aws_route_table_association" "bastion" {
  subnet_id      = aws_subnet.bastion.id
  route_table_id = aws_route_table.bastion.id
}


