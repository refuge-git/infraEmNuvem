# ID da VPC
output "vpc_id" {
  value = aws_vpc.vpc_cco.id
}

# -----------------------------------------------------------------------

# Subnets Públicas
output "subnets_publicas_ids" {
  value = aws_subnet.subnet_publica.id
}

# Subnets Privadas
output "subnets_privadas_ids" {
  value = aws_subnet.subnet_privada.id
}

# -----------------------------------------------------------------------

# Internet Gateway
output "igw_id" {
  value = aws_internet_gateway.igw_cco.id
}

# -----------------------------------------------------------------------

# Route Table Pública
output "route_table_publica_id" {
  value = aws_route_table.route_table_publica.id
}
