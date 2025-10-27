# -----------------------------------------------------------------------

# CONFIGURAÇÃO DAS EC2 PRIVADAS


resource "aws_instance" "ec2_privada_back1" {
  ami = var.id_ami
  instance_type = "t3.medium"
  key_name = var.key_name
  associate_public_ip_address = false

 user_data = <<-EOF
    #!/bin/bash
    set -e

    # Atualiza e instala Docker
    dnf update -y
    dnf install -y docker
    systemctl enable docker
    systemctl start docker

    # Cria pasta da aplicação
    mkdir -p /home/ec2-user/backend
    cd /home/ec2-user/backend

    # Copia arquivos necessários
    echo "${base64decode(filebase64("./scripts/Dockerfile"))}" > Dockerfile
    echo "${base64decode(filebase64("./scripts/compose-api.yaml"))}" > docker-compose.yaml

    # Build e start dos containers
    docker build -t api-spring .
    docker compose up -d
  EOF

  user_data_replace_on_change = true

  tags = {
    Name = "ec2-privada-BE-1"
  }


  vpc_security_group_ids = [var.sg_privada_id]
  subnet_id = var.subnet_privada_id
}

# -----------------------------------------------------------------------


resource "aws_instance" "ec2_privada_back2" {
  ami = var.id_ami
  instance_type = var.instancia_type_back
  key_name = var.key_name
  associate_public_ip_address = false

 user_data = join("\n\n", [
    "#!/bin/bash",
    file("./scripts/instalar_rabbitmq_amazon_linux.sh"),
    templatefile("./scripts/instalar_java.sh", {
      arquivo_docker_compose = base64encode(file("./scripts/compose-api.yaml"))
    })
  ])

  user_data_replace_on_change = true # para forçar atualização se o user_data mudar

  tags = {
    Name = "ec2-privada-BE-2"
  }

  vpc_security_group_ids = [var.sg_privada_id]
  subnet_id = var.subnet_privada_id
}