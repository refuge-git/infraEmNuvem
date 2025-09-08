variable "cidr_qualquer_ip" {
  description = "Qualquer IP do mundo"
  type        = string
  default     = "0.0.0.0/0"
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

variable "sg_egress_protocol" {
  default = "-1"
}

