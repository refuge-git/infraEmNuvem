#!/bin/bash

# Atualiza pacotes
sudo yum update -y

# Instala Docker
sudo amazon-linux-extras enable docker
sudo yum install -y docker

# Inicia e habilita Docker
sudo systemctl enable docker
sudo systemctl start docker

# Adiciona usuário ec2-user ao grupo docker
sudo usermod -aG docker ec2-user

# Instala Docker Compose (v2.29.2 - ajuste se quiser versão mais nova)
sudo curl -SL https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Baixa e sobe RabbitMQ (com painel de administração)
docker run -d \
  --name rabbitmq \
  -p 5672:5672 \
  -p 15672:15672 \
  rabbitmq:3-management

echo "Instalação concluída!"
echo "RabbitMQ rodando em:"
echo " - Porta AMQP: 5672"
echo " - Painel: http://<IP_DA_EC2>:15672 (usuário: guest / senha: guest)"
echo "Docker Compose versão instalada:"
docker-compose version

# Instalação do Grafana no Amazon Linux
echo "Instalando Grafana..."
sudo yum install -y wget
sudo yum install -y fontconfig
sudo wget https://dl.grafana.com/oss/release/grafana-10.2.3-1.x86_64.rpm
sudo yum install -y ./grafana-10.2.3-1.x86_64.rpm
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
echo "Grafana instalado e iniciado."
echo "Acesse: http://<IP_DA_EC2>:3000/login (user: admin, senha: admin)"