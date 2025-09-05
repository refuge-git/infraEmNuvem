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

# -----------------------------------------------------------------------

# MODULOS




# 1. Configura uma VPC com CIDR 10.0.0.0/24
# resource "aws_vpc" "vpc_cco" {
#   cidr_block = "10.0.0.0/26"
#   tags = {
#     Name = "vpc-2cco"
#   }
# }

# 2. Cria uma sub-rede pública com CIDR 10.0.0.0/28 # Uma sub-rede privada cpm CIDR 10.0.0.16/28
# resource "aws_subnet" "subnet_publica" {
#   vpc_id = aws_vpc.vpc_cco.id
#   cidr_block = "10.0.0.0/28"
#   tags = {
#     Name = "subrede-publica"
#   }
# }

# resource "aws_subnet" "subnet_privada" {
#   vpc_id = aws_vpc.vpc_cco.id
#   cidr_block = "10.0.0.16/28"
#   tags = {
#     Name = "subrede-privada"
#   }
# }

# # 3. Cria uma sub-rede privada com CIDR 10.0.0.32/28 # Uma sub-rede privada cpm CIDR 10.0.0.48/28
# resource "aws_subnet" "subnet_publica" {
#   vpc_id = aws_vpc.vpc_cco.id
#   cidr_block = "10.0.0.32/28"
#   tags = {
#     Name = "subrede-publica"
#   }
# }

# resource "aws_subnet" "subnet_privada" {
#   vpc_id = aws_vpc.vpc_cco.id
#   cidr_block = "10.0.0.48/28"
#   tags = {
#     Name = "subrede-privada"
#   }
# }

# 4. Configura uma Internet Gateway 
# resource "aws_internet_gateway" "igw_cco" {
#   vpc_id = aws_vpc.vpc_cco.id
#   tags = {
#     Name = "cco-igw"
#   }
# }

# 5. Configura a Route Table para a sub-rede pública
# resource "aws_route_table" "route_table_publica" {
#   vpc_id = aws_vpc.vpc_cco.id
#   route {
#     cidr_block = var.cidr_qualquer_ip
#     gateway_id = aws_internet_gateway.igw_cco.id
#   }
#   tags = {
#     Name = "subrede-publica-route-table"
#   }
# }

# # 6. Associa a Route Table à sub-rede pública
# resource "aws_route_table_association" "subrede_publica" {
#   subnet_id = aws_subnet.subnet_publica.id
#   route_table_id = aws_route_table.route_table_publica.id
# }

# # 7. Security Group para a instância pública
# resource "aws_security_group" "sg_publica" {
#   name = "sg_publica"
#   description = "Permite acesso SSH de qualquer IP"
#   vpc_id = aws_vpc.vpc_cco.id

#   ingress {
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_blocks = [var.cidr_qualquer_ip]
#   }

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = 0
#     cidr_blocks = [var.cidr_qualquer_ip]
#   }
# }

# # 8. Security Group para a instância privada
# resource "aws_security_group" "sg_privada" {
#   name = "sg_privada"
#   description = "Permite acesso SSH apenas da mesma VPC"
#   vpc_id = aws_vpc.vpc_cco.id

#   ingress {
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_blocks = [aws_vpc.vpc_cco.cidr_block]
#   }

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = [var.cidr_qualquer_ip]
#   }
# }

# 9. Instância EC2 pública
# resource "aws_instance" "ec2_publica_front1" {
#   ami = "ami-0e86e20dae9224db8"
#   instance_type = "t3.micro"
#   key_name = "vockey"
#   subnet_id = aws_subnet.subnet_publica.id
#   vpc_security_group_ids = [aws_security_group.sg_publica.id]x'
#   associate_public_ip_address = true

#   tags = {
#     Name ="ec2-publica-front1"
#   }
# }

# resource "aws_instance" "ec2_publica_front2" {
#   ami = "ami-0e86e20dae9224db8"
#   instance_type = "t3.micro"
#   key_name = "vockey"
#   subnet_id = aws_subnet.subnet_publica.id
#   vpc_security_group_ids = [aws_security_group.sg_publica.id]
#   associate_public_ip_address = true

#   tags = {
#     Name ="ec2-publica-front2"
#   }
# } 

# 10. Instância EC2 privada
# resource "aws_instance" "ec2_privada_back1" {
#   ami = "ami-0e86e20dae9224db8"
#   instance_type = "t3.micro"
#   key_name = "vockey"
#   subnet_id = aws_subnet.subnet_privada.id
#   vpc_security_group_ids = [aws_security_group.sg_privada.id]
#   associate_public_ip_address = false

#   tags = {
#     Name ="ec2-privada-back1"
#   }
# }

# resource "aws_instance" "ec2_privada_back2" {
#   ami = "ami-0e86e20dae9224db8"
#   instance_type = "t3.micro"
#   key_name = "vockey"
#   subnet_id = aws_subnet.subnet_privada.id
#   vpc_security_group_ids = [aws_security_group.sg_privada.id]
#   associate_public_ip_address = false

#   tags = {
#     Name ="ec2-privada-back2"
#   }
# }