resource "aws_vpc" "main" {
  cidr_block                       = "172.33.0.0/16"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  instance_tenancy                 = "default"
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name  = "${var.project}-${var.env}"
    Group = var.project
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name  = "${var.project}-${var.env}"
    Group = var.project
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  lifecycle {
    ignore_changes = [
      route,
    ]
  }

  tags = {
    Name  = "${var.project}-${var.env}-public"
    Group = var.project
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block                = "172.31.0.0/16"
    vpc_peering_connection_id = data.terraform_remote_state.common.outputs.aws_vpc_peering_connection_id_stg
  }

  tags = {
    Name  = "${var.project}-${var.env}-private"
    Group = var.project
  }
}

resource "aws_subnet" "public-primary" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.33.0.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name  = "${var.project}-${var.env}-public-primary"
    Group = var.project
  }
}

resource "aws_subnet" "public-secondary" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.33.1.0/24"
  availability_zone       = "${var.region}c"
  map_public_ip_on_launch = true

  tags = {
    Name  = "${var.project}-${var.env}-public-secondary"
    Group = var.project
  }
}

resource "aws_subnet" "public-tertiary" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.33.2.0/24"
  availability_zone       = "${var.region}d"
  map_public_ip_on_launch = true

  tags = {
    Name  = "${var.project}-${var.env}-public-tertiary"
    Group = var.project
  }
}

resource "aws_subnet" "private-primary" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.33.3.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name  = "${var.project}-${var.env}-private-primary"
    Group = var.project
  }
}

resource "aws_subnet" "private-secondary" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.33.4.0/24"
  availability_zone       = "${var.region}c"
  map_public_ip_on_launch = true

  tags = {
    Name  = "${var.project}-${var.env}-private-secondary"
    Group = var.project
  }
}

resource "aws_subnet" "private-tertiary" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.33.5.0/24"
  availability_zone       = "${var.region}d"
  map_public_ip_on_launch = true

  tags = {
    Name  = "${var.project}-${var.env}-private-tertiary"
    Group = var.project
  }
}

resource "aws_route_table_association" "public-primary" {
  subnet_id      = aws_subnet.public-primary.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-secondary" {
  subnet_id      = aws_subnet.public-secondary.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-tertiary" {
  subnet_id      = aws_subnet.public-tertiary.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private-primary" {
  subnet_id      = aws_subnet.private-primary.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-secondary" {
  subnet_id      = aws_subnet.private-secondary.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-tertiary" {
  subnet_id      = aws_subnet.private-tertiary.id
  route_table_id = aws_route_table.private.id
}
