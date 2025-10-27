# -----------------------------------------------------------------------
# CONFIGURAÇÃO DAS EC2 PÚBLICAS

resource "aws_instance" "ec2_publica_front1" {
  ami                         = var.id_ami
  instance_type                = "t3.medium"
  key_name                     = var.key_name
  associate_public_ip_address  = true
  vpc_security_group_ids       = [var.sg_publica_id]
  subnet_id                    = var.subnet_publica_id

  user_data = join("\n\n", [
    "#!/bin/bash",
    file("./scripts/instalar_rabbitmq_amazon_linux.sh"),
    file("./scripts/instalar_nginx.sh")
  ])

  user_data_replace_on_change = true # para forçar atualização se o user_data mudar

  connection {
    type        = "ssh"
    user        = "ec2-user" # Ou 'ubuntu', 'centos', dependendo da AMI que escolheu
    private_key = file("./modules/instances/labsuser.pem")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "./scripts/compose-nginx.yaml" # arquivo docker-compose para o NGINX
    destination = "/home/ec2-user/compose.yaml"
    # OU destination = "/home/ubuntu/compose.yaml" # se for AMI Ubuntu
  }

  tags = {
    Name = "ec2-publica-FE-1"
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

  user_data = join("\n\n", [
    "#!/bin/bash",
    file("./scripts/instalar_rabbitmq_amazon_linux.sh"),
    file("./scripts/instalar_nginx.sh")
  ])

  user_data_replace_on_change = true # para forçar atualização se o user_data mudar

  connection {
    type        = "ssh"
    user        = "ec2-user" # Ou 'ubuntu', 'centos', dependendo da AMI que escolheu
    private_key = file("./modules/instances/labsuser.pem")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "./scripts/compose-nginx.yaml" # arquivo docker-compose para o NGINX
    destination = "/home/ec2-user/compose.yaml"
    # OU destination = "/home/ubuntu/compose.yaml" # se for AMI Ubuntu
  }

  tags = {
    Name = "ec2-publica-FE-2"
  }
}

