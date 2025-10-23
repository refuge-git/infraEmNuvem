terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }
  required_version = ">= 1.2"
}

provider "aws" {
  region = "us-east-1"
}

# Módulo de rede
module "network" {
  source = "./modules/network"
}

# Módulo de security groups
module "security" {
  source   = "./modules/security"
  vpc_id   = module.network.vpc_id
  vpc_cidr = "10.0.0.0/24"
}

# Módulo de instâncias
module "instances" {
  source            = "./modules/instances"
  subnet_publica_id = module.network.public_subnet_ids[0]
  subnet_privada_id = module.network.private_subnet_ids[0]
  sg_publica_id     = module.security.sg_publica_id
  sg_privada_id     = module.security.sg_privada_id
  key_name          = "vockey"
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = "s3-refuge-achiropita"
}

module "alb" {
  source             = "./modules/alb"
  vpc_id             = module.network.vpc_id
  subnet_ids = [module.network.public_subnet_ids[0], module.network.private_subnet_ids[0]]
  ec2_instance_1_id  = module.instances.ec2_privada_back1_id
  ec2_instance_2_id  = module.instances.ec2_privada_back2_id
}

module "lambda" {
  source = "./modules/lambda"

  lambda_function_name = "funcao1_terraform"
  lambda_handler       = "lambda_function.lambda_handler"
  lambda_runtime       = "python3.9"
  lambda_role_name     = "LabRole"
}




# 15.1. Security group para o RabbitMQ 
resource "aws_security_group" "rabbitmq_sg" {
  name        = "rabbitmq-sg"
  description = "Permite trafego para RabbitMQ e SSH"
  vpc_id      = module.network.vpc_id

  # Regra para SSH (Porta 22)
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Regra para RabbitMQ AMQP (Porta 5672)
  ingress {
    description = "RabbitMQ AMQP"
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Cuidado com isso em produção!
  }

  # Regra para RabbitMQ Management UI (Porta 15672)
  ingress {
    description = "RabbitMQ UI"
    from_port   = 15672
    to_port     = 15672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Cuidado com isso em produção!
  }

  # Regra de Saída (Outbound) - Permite todo o tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG RabbitMQ"
  }
}


# 15.2. Criando uma instância EC2 na sub-rede pública 
resource "aws_instance" "ec2_publica_rabbitmq1" {
  ami                         = "ami-00ca32bbc84273381" # usar o mesmo da outra Ec2 pública
  instance_type               = "t2.micro" 
  key_name                    = "vockey"
  subnet_id                   = module.network.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.rabbitmq_sg.id]
  associate_public_ip_address = true

  connection {
    type        = "ssh"
    user        = "ec2-user" # Ou 'ubuntu', 'centos', dependendo da AMI que escolheu
    private_key = file("./modules/instances/labsuser.pem") # Sempre colocar a chave .pem dentro de /instances
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "scripts/compose-rabbitmq.yaml" # arquivo docker-compose para o RabbitMQ
    destination = "/home/ec2-user/compose.yaml"
    # OU destination = "/home/ubuntu/compose.yaml" # se for AMI Ubuntu
  }

  user_data = file("./scripts/instalar_rabbitmq_amazon_linux.sh") # script para instalar o RabbitMQ

  tags = {
    Name = "ec2-publica-rabbitmq"
  }
}


output "ip_publico_rabbitmq" {
  description = "IP Público da instância EC2 do RabbitMQ"
  value       = aws_instance.ec2_publica_rabbitmq1.public_ip
}

output "url_gerenciador_rabbitmq" {
  description = "URL do Management UI do RabbitMQ"
  value       = "http://${aws_instance.ec2_publica_rabbitmq1.public_ip}:15672"
}


# Instância EC2 para o banco de dados MySQL

# resource "aws_security_group" "sg_mysql" {
#   name        = "sg_mysql"
#   description = "Permite acesso MySQL e SSH"
#   vpc_id      = module.network.vpc_id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 3306
#     to_port     = 3306
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] 
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_instance" "ec2_publica_mysql" {
#   ami                         = "ami-00ca32bbc84273381"
#   instance_type               = "t2.micro" 
#   key_name                    = "vockey"
#   subnet_id                   = module.network.private_subnet_ids[0]
#   vpc_security_group_ids      = [aws_security_group.sg_mysql.id]
#   associate_public_ip_address = true

#   user_data = join("\n\n", [
#     "#!/bin/bash",
#     file("./scripts/instalar_docker_amazon_linux.sh"),
#     "docker-compose -f /home/ec2-user/compose-bd.yaml up -d"
#   ])

#   user_data_replace_on_change = true # para forçar atualização se o user_data mudar

#   connection {
#     type        = "ssh"
#     user        = "ec2-user"
#     private_key = file("./modules/instances/labsuser.pem")
#     host        = self.public_ip
#   }

#   provisioner "file" {
#     source      = "./scripts/compose-bd.yaml"
#     destination = "/home/ec2-user/compose-bd.yaml"
#   }

#   provisioner "file" {
#     source      = "./scripts/init.sql"
#     destination = "/home/ec2-user/init.sql"
#   }

#   tags = {
#     Name = "ec2-publica-mysql"
#   }
# }
