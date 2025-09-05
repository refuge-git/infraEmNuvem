# -----------------------------------------------------------------------

# CONFIGURAÇÃO DAS EC2 PÚBLICAS

resource "aws_instance" "ec2_publica_front1" {
  ami = var.id_ami
  instance_type = var.instancia_type_front

  # key_name = "vockey"
  associate_public_ip_address = true

  tags = {
    Name ="ec2-publica-front1"
  }

  vpc_security_group_ids = [var.sg_publica_id]
  subnet_id = var.subnet_publica_id

}

# -----------------------------------------------------------------------

resource "aws_instance" "ec2_publica_front2" {
  ami = var.id_ami
  instance_type = var.instancia_type_front

  key_name = "vockey"
  vpc_security_group_ids = [var.sg_publica_id]
  associate_public_ip_address = true

  tags = {
    Name ="ec2-publica-front2"
  }

  subnet_id = var.subnet_publica_id

} 