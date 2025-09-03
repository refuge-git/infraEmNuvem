# -----------------------------------------------------------------------

# CONFIGURAÇÃO DAS EC2 PÚBLICAS

resource "aws_instance" "ec2_publica_front1" {
  ami = var.id_ami
  instance_type = var.instancia_type_front

  key_name = "vockey"
  vpc_security_group_ids = [aws_security_group.sg_publica.id]
  associate_public_ip_address = true

  tags = {
    Name ="ec2-publica-front1"
  }

  subnet_id = aws_subnet.subnet_publica.id

}

# -----------------------------------------------------------------------

resource "aws_instance" "ec2_publica_front2" {
  ami = var.id_ami
  instance_type = var.instancia_type_front

  key_name = "vockey"
  vpc_security_group_ids = [aws_security_group.sg_publica.id]
  associate_public_ip_address = true

  tags = {
    Name ="ec2-publica-front2"
  }

  subnet_id = aws_subnet.subnet_publica.id

} 