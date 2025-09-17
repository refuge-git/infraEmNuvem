# ID da VPC
output "vpc_id" {
  value = aws_vpc.main.id
}

# -----------------------------------------------------------------------

# Subnets Públicas
output "public_subnet_ids" {
  value = [aws_subnet.subnet_publica1.id, aws_subnet.subnet_publica2.id] 
}

# Subnets Privadas
output "private_subnet_ids" {
  value = [aws_subnet.subnet_privada1.id, aws_subnet.subnet_privada2.id]
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
