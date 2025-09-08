# -----------------------------------------------------------------------

# CONFIGURAÇÃO DA VPC

resource "aws_vpc" "vpc_cco" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}
# -----------------------------------------------------------------------

# CONFIGURAÇÃO DAS SUB-REDES

resource "aws_subnet" "subnet_publica" {
  vpc_id = aws_vpc.vpc_cco.id
  cidr_block = var.subnet_publica_cidrs
  tags = {
    Name = var.subnet_publica_name
  }
}

resource "aws_subnet" "subnet_privada" {
  vpc_id = aws_vpc.vpc_cco.id
  cidr_block = var.subnet_privada_cidrs
  tags = {
    Name = var.subnet_privada_name
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
    Name = var.igw_name
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
    Name = var.route_table_publica_name
  }
}

# cONFIGURAÇÃO DA ROUTE TABLE PRIVADA

# -----------------------------------------------------------------------

# 6. Associa a Route Table à sub-rede pública
resource "aws_route_table_association" "subrede_publica" {
  subnet_id = aws_subnet.subnet_publica.id
  route_table_id = aws_route_table.route_table_publica.id
}
