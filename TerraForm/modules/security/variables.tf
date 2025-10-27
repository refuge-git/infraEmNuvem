variable "cidr_qualquer_ip" {
  description = "Qualquer IP do mundo"
  type        = string
  default     = "0.0.0.0/0"
}

# -----------------------------------------------------------------------
# Variáveis para integração com a VPC
# -----------------------------------------------------------------------

variable "vpc_id" {
  description = "ID da VPC onde os security groups serão criados"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR da VPC (para regras de acesso interno)"
  type        = string
}

# -----------------------------------------------------------------------

variable "sg_publica_name" {
  default = "sg_publica"
}

variable "sg_publica_desc" {
  default = "Permite acesso SSH de qualquer IP"
}

# -----------------------------------------------------------------------

variable "sg_privada_name" {
  default = "sg_privada"
}

variable "sg_privada_desc" {
  default = "Permite acesso SSH apenas da mesma VPC"
}

# -----------------------------------------------------------------------


variable "ssh_port" {
  default = 22
}

variable "sg_ingress_protocol" {
  default = "tcp"
}

variable "sg_egress_protocol" {
  default = 0
}

# variable "sg_egress_protocol1" {
#   default = "-1"
# }

variable "sg_egress_protocol_priv" {
  description = "Protocolo de egress para a SG privada"
  type        = string
  default     = "-1"
}



