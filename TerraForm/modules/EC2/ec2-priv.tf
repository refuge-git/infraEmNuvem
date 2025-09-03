# -----------------------------------------------------------------------

# CONFIGURAÇÃO DAS EC2 PRIVADAS


resource "aws_instance" "ec2_privada_back1" {
  ami = var.id_ami
  instance_type = var.instancia_type_back

  key_name = "vockey"
  vpc_security_group_ids = [aws_security_group.sg_privada.id]
  associate_public_ip_address = false

  tags = {
    Name ="ec2-privada-back1"
  }

  subnet_id = aws_subnet.subnet_privada.id

}

# -----------------------------------------------------------------------


resource "aws_instance" "ec2_privada_back2" {
  ami = var.id_ami
  instance_type = var.instancia_type_back

  key_name = "vockey"
  vpc_security_group_ids = [aws_security_group.sg_privada.id]
  associate_public_ip_address = false

  tags = {
    Name ="ec2-privada-back2"
  }

  subnet_id = aws_subnet.subnet_privada.id

}