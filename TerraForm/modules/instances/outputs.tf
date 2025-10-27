# IDs das instâncias

output "ec2_privada_back1_id" {
  description = "ID da instância privada back1"
  value       = aws_instance.ec2_privada_back1.id
}

output "ec2_privada_back2_id" {
  description = "ID da instância privada back2"
  value       = aws_instance.ec2_privada_back2.id
}

output "ec2_publica_front1_id" {
  description = "ID da instância pública front1"
  value = aws_instance.ec2_publica_front1
}


output "ec2_publica_front2_id" {
  description = "ID da instância pública front2"
  value = aws_instance.ec2_publica_front2
}

# -----------------------------------------------------------------------



