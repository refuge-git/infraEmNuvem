# -----------------------------------------------------------------------

# CONFIGURAÇÃO DA VPC

resource "aws_vpc" "vpc_cco" {
  cidr_block = "10.0.0.0/26"
  tags = {
    Name = "vpc-2cco"
  }
}
# -----------------------------------------------------------------------

# CONFIGURAÇÃO DAS SUB-REDES

resource "aws_subnet" "subnet_publica" {
  vpc_id = aws_vpc.vpc_cco.id
  cidr_block = "10.0.0.0/28"
  tags = {
    Name = "subrede-publica"
  }
}

resource "aws_subnet" "subnet_privada" {
  vpc_id = aws_vpc.vpc_cco.id
  cidr_block = "10.0.0.16/28"
  tags = {
    Name = "subrede-privada"
  }
}

resource "aws_subnet" "subnet_publica" {
  vpc_id = aws_vpc.vpc_cco.id
  cidr_block = "10.0.0.32/28"
  tags = {
    Name = "subrede-publica"
  }
}

resource "aws_subnet" "subnet_privada" {
  vpc_id = aws_vpc.vpc_cco.id
  cidr_block = "10.0.0.48/28"
  tags = {
    Name = "subrede-privada"
  }
}
# -----------------------------------------------------------------------

# CONFIGURAÇÃO DO INTERNET GATEWAY

resource "aws_internet_gateway" "igw_cco" {
  vpc_id = aws_vpc.vpc_cco.id
  tags = {
    Name = "cco-igw"
  }
}
# -----------------------------------------------------------------------

# CONFIGURAÇÃO DA ROUTE TABLE PUBLICA

resource "aws_route_table" "route_table_publica" {
  vpc_id = aws_vpc.vpc_cco.id
  route {
    cidr_block = var.cidr_qualquer_ip
    gateway_id = aws_internet_gateway.igw_cco.id
  }
  tags = {
    Name = "subrede-publica-route-table"
  }
}

# cONFIGURAÇÃO DA ROUTE TABLE PRIVADA

# -----------------------------------------------------------------------