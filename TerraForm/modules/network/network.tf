# NAT Gateway e EIP para subnet_publica2
resource "aws_eip" "nat_gateway_eip_2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "main_2" {
  allocation_id = aws_eip.nat_gateway_eip_2.id
  subnet_id     = aws_subnet.subnet_publica2.id
  depends_on    = [aws_internet_gateway.igw_cco]
}

# Tabela de Rotas Privada para subnet_privada2
resource "aws_route_table" "route_table_privada_2" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main_2.id
  }
  tags = {
    Name = "route-table-privada-2"
  }
}

# Associação da Tabela de Rotas Privada à subnet_privada2
resource "aws_route_table_association" "subrede_privada2_nat2" {
  subnet_id      = aws_subnet.subnet_privada2.id
  route_table_id = aws_route_table.route_table_privada_2.id
}
# 11.1. Elastic IP para o NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  domain = "vpc"
}

# 11.2. NAT Gateway associado à subnet pública 1
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.subnet_publica1.id
  depends_on    = [aws_internet_gateway.igw_cco]
}

# 11.3. Tabela de Rotas Privada
resource "aws_route_table" "route_table_privada" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = {
    Name = "route-table-privada"
  }
}

# 11.4. Associação da Tabela de Rotas Privada às Subnets Privadas
resource "aws_route_table_association" "subrede_privada1" {
  subnet_id      = aws_subnet.subnet_privada1.id
  route_table_id = aws_route_table.route_table_privada.id
}

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
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.subnet_publica_name}-1"
  }
}

resource "aws_subnet" "subnet_privada1" {
  vpc_id = aws_vpc.main.id
  availability_zone = "us-east-1a"
  cidr_block = var.subnet_privada_cidrs[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.subnet_privada_name}-1"
  }
}

resource "aws_subnet" "subnet_publica2" {
  vpc_id = aws_vpc.main.id
  availability_zone = "us-east-1b"
  cidr_block = var.subnet_publica_cidrs[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.subnet_publica_name}-2"
  }
}

resource "aws_subnet" "subnet_privada2" {
  vpc_id = aws_vpc.main.id
  availability_zone = "us-east-1b"
  cidr_block = var.subnet_privada_cidrs[1]
  map_public_ip_on_launch = false
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

