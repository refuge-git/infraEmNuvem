# -----------------------------------------------------------------------

# CONFIGURAÇÃO DAS EC2 PRIVADAS


resource "aws_instance" "ec2_privada_back1" {
  ami = var.id_ami
  instance_type = var.instancia_type_back

  # key_name = "vockey"
  associate_public_ip_address = false

  tags = {
    Name ="ec2-privada-back1"
  }


  vpc_security_group_ids = [var.sg_privada_id]
  subnet_id = var.subnet_privada_id

}

# -----------------------------------------------------------------------


resource "aws_instance" "ec2_privada_back2" {
  ami = var.id_ami
  instance_type = var.instancia_type_back

  # key_name = "vockey"
  associate_public_ip_address = false

  tags = {
    Name ="ec2-privada-back2"
  }

  vpc_security_group_ids = [var.sg_privada_id]
  subnet_id = var.subnet_privada_id

}