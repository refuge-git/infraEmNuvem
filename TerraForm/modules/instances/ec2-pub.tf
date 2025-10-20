# -----------------------------------------------------------------------
# CONFIGURAÇÃO DAS EC2 PÚBLICAS

resource "aws_instance" "ec2_publica_front1" {
  ami                         = var.id_ami
  instance_type                = var.instancia_type_front
  key_name                     = var.key_name
  associate_public_ip_address  = true
  vpc_security_group_ids       = [var.sg_publica_id]
  subnet_id                    = var.subnet_publica_id

  connection {
    type        = "ssh"
    user        = "ec2-user" # ou "ubuntu"
    private_key = file("${path.module}/vockey.pem") # Sempre colocar a chave .pem dentro de /instances
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "${path.module}/compose.yaml" # Sempre colocar o arquivo yaml dentro de /instances
    destination = "/home/ec2-user/compose.yaml"
  }

  user_data = file("${path.module}/install_rabbitmq_docker.sh")

  tags = {
    Name = "ec2-publica-front1"
  }
}

# -----------------------------------------------------------------------

resource "aws_instance" "ec2_publica_front2" {
  ami                         = var.id_ami
  instance_type                = var.instancia_type_front
  key_name                     = var.key_name
  associate_public_ip_address  = true
  vpc_security_group_ids       = [var.sg_publica_id]
  subnet_id                    = var.subnet_publica_id

  connection {
    type        = "ssh"
    user        = "ec2-user" # ou "ubuntu"
    private_key = file("${path.module}/vockey.pem") # Sempre colocar a chave .pem dentro de /instances
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "${path.module}/compose.yaml" # Sempre colocar o arquivo yaml dentro de /instances
    destination = "/home/ec2-user/compose.yaml"
  }

  user_data = file("${path.module}/install_rabbitmq_docker.sh")

  tags = {
    Name = "ec2-publica-front2"
  }
}

# Instância EC2 para o banco de dados MySQL

resource "aws_instance" "ec2_publica_mysql" {
  ami                         = "ami-00ca32bbc84273381"
  instance_type               = var.instancia_type_front
  key_name                    = "vockey"
  subnet_id                   = var.subnet_publica_id
  vpc_security_group_ids      = [aws_security_group.sg_mysql.id]
  associate_public_ip_address = true

  user_data = join("\n\n", [
    "#!/bin/bash",
    file("${path.module}/instalar_docker_amazon_linux.sh"),
    "docker-compose -f /home/ec2-user/compose-bd.yaml up -d"
  ])

  user_data_replace_on_change = true # para forçar atualização se o user_data mudar

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./labsuser.pem")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "${path.module}/compose-bd.yaml"
    destination = "/home/ec2-user/compose-bd.yaml"
  }

  provisioner "file" {
    source      = "${path.module}/init.sql"
    destination = "/home/ec2-user/init.sql"
  }

  tags = {
    Name = "ec2-publica-mysql"
  }
}
