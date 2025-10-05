# variable "id_ami"{
#     default = "ami-0e86e20dae9224db8"
#     }
# # -----------------------------------------------------------------------

# variable "instancia_type_back"{
#     default = "t3.micro"
#     }
    
# # -----------------------------------------------------------------------
    
# variable "instancia_type_front"{
#     default = "t3.micro"
#     }


variable "id_ami" {
  description = "AMI usada para as instâncias"
  type        = string
  # default     = "ami-0e86e20dae9224db8"
  default = "ami-00ca32bbc84273381"
}

# -----------------------------------------------------------------------

variable "instancia_type_back" {
  description = "Tipo da instância backend"
  type        = string
  default     = "t2.micro"
}

variable "sg_privada_id" {
  description = "ID do Security Group das instâncias privadas"
  type        = string
}

variable "subnet_privada_id" {
  description = "ID da Subnet privada"
  type        = string
}

# -----------------------------------------------------------------------

variable "instancia_type_front" {
  description = "Tipo da instância frontend"
  type        = string
  default     = "t2.micro"
}

variable "sg_publica_id" {
  description = "ID do Security Group das instâncias públicas"
  type        = string
}


variable "subnet_publica_id" {
  description = "ID da Subnet pública"
  type        = string
}

# Par de chaves SSH
variable "key_name" {
  description = "Nome do par de chaves para acesso SSH"
  type        = string
}

