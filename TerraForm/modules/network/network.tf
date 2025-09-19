# -----------------------------------------------------------------------

# CONFIGURAÇÃO DA VPC

# resource "aws_vpc" "vpc_cco" {
#   cidr_block = var.vpc_cidr
#   tags = {
#     Name = var.vpc_name
#   }
# }

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}
# -----------------------------------------------------------------------

# CONFIGURAÇÃO DAS SUB-REDES

resource "aws_subnet" "subnet_publica1" {
  vpc_id = aws_vpc.main.id
  availability_zone = "us-east-1a"
  cidr_block = var.subnet_publica_cidrs[0]
  tags = {
    Name = "${var.subnet_publica_name}-1"
  }
}

resource "aws_subnet" "subnet_privada1" {
  vpc_id = aws_vpc.main.id
  availability_zone = "us-east-1b"
  cidr_block = var.subnet_privada_cidrs[0]
  tags = {
    Name = "${var.subnet_privada_name}-1"
  }
}

resource "aws_subnet" "subnet_publica2" {
  vpc_id = aws_vpc.main.id
  availability_zone = "us-east-1c"
  cidr_block = var.subnet_publica_cidrs[1]
  tags = {
    Name = "${var.subnet_publica_name}-2"
  }
}

resource "aws_subnet" "subnet_privada2" {
  vpc_id = aws_vpc.main.id
  availability_zone = "us-east-1d"
  cidr_block = var.subnet_privada_cidrs[1]
  tags = {
    Name = "${var.subnet_privada_name}-2"
  }
}
# -----------------------------------------------------------------------

# CONFIGURAÇÃO DO INTERNET GATEWAY

resource "aws_internet_gateway" "igw_cco" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = var.igw_name
  }
}
# -----------------------------------------------------------------------

# CONFIGURAÇÃO DA ROUTE TABLE PUBLICA

resource "aws_route_table" "route_table_publica" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = var.cidr_qualquer_ip
    gateway_id = aws_internet_gateway.igw_cco.id
  }
  tags = {
    Name = var.route_table_publica_name
  }
}

# cONFIGURAÇÃO DA ROUTE TABLE PRIVADA

# -----------------------------------------------------------------------

# 6. Associa a Route Table à sub-rede pública
resource "aws_route_table_association" "subrede_publica1" {
  subnet_id = aws_subnet.subnet_publica1.id
  route_table_id = aws_route_table.route_table_publica.id
}

resource "aws_route_table_association" "subrede_publica2" {
  subnet_id      = aws_subnet.subnet_publica2.id
  route_table_id = aws_route_table.route_table_publica.id
}

