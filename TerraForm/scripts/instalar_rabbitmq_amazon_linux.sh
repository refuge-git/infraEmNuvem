#!/bin/bash

# Atualiza pacotes
sudo dnf update -y

# Instala Docker
sudo dnf install -y docker
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user

# Instala Docker Compose (v2)
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Sobe o RabbitMQ usando o arquivo compose
cd /home/ec2-user
sudo docker-compose -f compose.yaml up -d

# Permite que o ec2-user acesse os arquivos
sudo chown ec2-user:ec2-user /home/ec2-user/compose.yaml

echo "RabbitMQ instalado e rodando!"