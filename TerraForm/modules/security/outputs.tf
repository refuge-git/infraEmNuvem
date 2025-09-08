# ID do Security Group Público
output "sg_publica_id" {
  value = aws_security_group.sg_publica.id
}

# Nome do Security Group Público 
output "sg_publica_name" {
  value = aws_security_group.sg_publica.name
}

# -----------------------------------------------------------------------

# ID do Security Group Privado
output "sg_privada_id" {
  value = aws_security_group.sg_privada.id
}

# Nome do Security Group Privado 
output "sg_privada_name" {
  value = aws_security_group.sg_privada.name
}

# -----------------------------------------------------------------------
