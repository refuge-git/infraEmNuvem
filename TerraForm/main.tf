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
  vpc_cidr = "10.0.0.0/16"
  alb_sg_id = aws_security_group.alb_sg.id
}

# Módulo de instâncias
module "instances" {
  source            = "./modules/instances"
  subnet_publica_id = module.network.public_subnet_ids[0]
  subnet_privada_id = module.network.private_subnet_ids[0]
  sg_publica_id     = module.security.sg_publica_id
  sg_privada_id     = module.security.sg_privada_id
  key_name          = "vockey"
  private_key_path  = "./modules/instances/labsuser.pem"
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = "s3-refuge-achiropita"
}



# Bucket RAW (upload público para Lambda)
resource "aws_s3_bucket" "raw" {
  bucket = "bucket-refuge-img-raw"
  acl    = "private"

  tags = {
    Name = "Bucket RAW"
  }
}

resource "aws_s3_bucket_public_access_block" "raw_public_access" {
  bucket = aws_s3_bucket.raw.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

# Permissão pública para upload no RAW
resource "aws_s3_bucket_policy" "raw_public_write" {
  bucket = aws_s3_bucket.raw.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicUpload"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:PutObject"]
        Resource  = "arn:aws:s3:::${aws_s3_bucket.raw.bucket}/*"
      }
    ]
  })
}

# Bucket TRUSTED (leitura pública)
resource "aws_s3_bucket" "trusted" {
  bucket = "bucket-refuge-img-trusted"
  acl    = "private"

  tags = {
    Name = "Bucket TRUSTED"
  }
}

resource "aws_s3_bucket_public_access_block" "trusted_public_access" {
  bucket = aws_s3_bucket.trusted.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

# Permissão pública para leitura no TRUSTED
resource "aws_s3_bucket_policy" "trusted_public_read" {
  bucket = aws_s3_bucket.trusted.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = "arn:aws:s3:::${aws_s3_bucket.trusted.bucket}/*"
      }
    ]
  })
}



# module "alb" {
#   source             = "./modules/alb"
#   vpc_id             = module.network.vpc_id
#   subnet_ids = [module.network.public_subnet_ids[0], module.network.private_subnet_ids[0]]
#   ec2_instance_1_id  = module.instances.ec2_privada_back1_id
#   ec2_instance_2_id  = module.instances.ec2_privada_back2_id
# }



module "lambda" {
  source = "./modules/lambda"

  lambda_function_name = "funcao1_terraform"
  lambda_handler       = "lambda_function.lambda_handler"
  lambda_runtime       = "python3.11"
  lambda_role_name     = "LabRole"

  lambda_layers = [aws_lambda_layer_version.pillow.arn]
}

# Layer do Pillow para imports do python da lambda
resource "aws_lambda_layer_version" "pillow" {
  layer_name          = "pillow-layer"
  description         = "Pillow 10.2.0 para Python 3.11"
  compatible_runtimes = ["python3.11"]
  filename = "../lambda/layers/pillow/pillow-layer.zip"
}

# Trigger para a lambda invocar o S3
# Permissão para o S3 invocar a Lambda
resource "aws_lambda_permission" "allow_s3_raw" {
  statement_id  = "AllowS3InvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw.arn
}

# Notificação do bucket RAW para a Lambda
resource "aws_s3_bucket_notification" "raw_bucket_trigger" {
  bucket = aws_s3_bucket.raw.id

  lambda_function {
    lambda_function_arn = module.lambda.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3_raw]
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


# module "alb" {
#   source             = "./modules/alb"
#   vpc_id             = module.network.vpc_id
#   subnet_ids = [module.network.public_subnet_ids[0], module.network.private_subnet_ids[0]]
#   ec2_instance_1_id  = module.instances.ec2_privada_back1_id
#   ec2_instance_2_id  = module.instances.ec2_privada_back2_id
# }


# =====================================================
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg-web-access"
  description = "Permite acesso HTTP publico ao ALB"
  vpc_id      = module.network.vpc_id

  # Entrada HTTP pública (porta 80)
  ingress {
    description = "Chamadas HTTP da internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Saída liberada para qualquer destino
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg-web-access"
  }
}

resource "aws_security_group" "backend_sg" {
  name        = "backend-sg"
  description = "Permite trafego do ALB para o backend"
  vpc_id      = module.network.vpc_id

  ingress {
    description      = "Permite trafego HTTP do ALB"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backend-sg"
  }
}


resource "aws_lb_target_group" "web_tg" {
  name        = "web-target-group-app"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = module.network.vpc_id
  target_type = "instance"

  # Health check para validar o backend
  health_check {
    path                = "/actuator/health" # ajuste conforme sua API
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  tags = {
    Name = "web-tg-backend"
  }
}


resource "aws_lb" "alb_principal" {
  name               = "alb-principal"
  internal           = false                   # público
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [                      # SOMENTE SUBNETS PÚBLICAS
    module.network.public_subnet_ids[0],
    module.network.public_subnet_ids[1]
  ]

  tags = {
    Name = "ALBPrincipal"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb_principal.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "backend_attach" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = module.instances.ec2_privada_back1_id  # EC2 do backend
  port             = 8080                                     # Porta do backend
}

output "alb_dns_name" {
  value = aws_lb.alb_principal.dns_name
}