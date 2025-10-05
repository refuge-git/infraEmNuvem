# -----------------------------------------------------------------------

# CONFIGURAÇÃO DAS EC2 PÚBLICAS

resource "aws_instance" "ec2_publica_front1" {
  ami = var.id_ami
  instance_type = var.instancia_type_front
  key_name = var.key_name
  associate_public_ip_address = true

 connection {
    type        = "ssh"
    user        = "ec2-user" # Ou 'ubuntu', 'centos', dependendo da AMI que escolheu
    private_key = file("C:\\Users\\beatr\\Downloads\\labsuser.pem")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "C:\\Users\\beatr\\OneDrive\\Material 2CCO\\Pesquisa e Inovação 2\\infraEmNuvem\\TerraForm\\compose.yaml" # arquivo docker-compose para o RabbitMQ
    destination = "/home/ec2-user/compose.yaml"
    # OU destination = "/home/ubuntu/compose.yaml" # se for AMI Ubuntu
  }

  user_data = file("C:\\Users\\beatr\\OneDrive\\Material 2CCO\\Pesquisa e Inovação 2\\infraEmNuvem\\TerraForm\\modules\\instances\\install_rabbitmq_docker.sh") # script para instalar o RabbitMQ

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
  key_name = var.key_name
  vpc_security_group_ids = [var.sg_publica_id]
  associate_public_ip_address = true

 connection {
    type        = "ssh"
    user        = "ec2-user" # Ou 'ubuntu', 'centos', dependendo da AMI que escolheu
    private_key = file("C:\\Users\\beatr\\Downloads\\labsuser.pem")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "C:\\Users\\beatr\\OneDrive\\Material 2CCO\\Pesquisa e Inovação 2\\infraEmNuvem\\TerraForm\\compose.yaml" # arquivo docker-compose para o RabbitMQ
    destination = "/home/ec2-user/compose.yaml"
    # OU destination = "/home/ubuntu/compose.yaml" # se for AMI Ubuntu
  }

  user_data = file("C:\\Users\\beatr\\OneDrive\\Material 2CCO\\Pesquisa e Inovação 2\\infraEmNuvem\\TerraForm\\modules\\instances\\install_rabbitmq_docker.sh") # script para instalar o RabbitMQ

  tags = {
    Name ="ec2-publica-front2"
  }

  subnet_id = var.subnet_publica_id
}