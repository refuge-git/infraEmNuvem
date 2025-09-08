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
  subnet_publica_id = module.network.public_subnet_id
  subnet_privada_id = module.network.private_subnet_id
  sg_publica_id     = module.security.sg_publica_id
  sg_privada_id     = module.security.sg_privada_id
}