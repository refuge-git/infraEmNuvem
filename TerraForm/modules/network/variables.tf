variable "vpc_cidr" {
  default = "10.0.0.0/26"
}

variable "vpc_name" {
  default = "vpc-2cco"
}

# -----------------------------------------------------------------------

variable "subnet_publica_cidrs" {
  default = ["10.0.0.0/28", "10.0.0.32/28"]
}   

variable "subnet_publica_name" {
  default = "subrede-publica"
}

variable "subnet_privada_cidrs" {
default = ["10.0.0.16/28", "10.0.0.48/28"]
}

variable "subnet_privada_name" {
  default = "subrede-privada"
}

# -----------------------------------------------------------------------

variable "igw_name" {
  default = "cco-igw"
}

# -----------------------------------------------------------------------

variable "route_table_publica_name" {
  default = "subrede-publica-route-table"
}

variable "cidr_qualquer_ip" {
  description = "Qualquer IP do mundo"
  type        = string
  default     = "0.0.0.0/0"
}
