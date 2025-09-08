# -----------------------------------------------------------------------

# SECURITY GROUP PARA INSTANCIA PUBLICA

resource "aws_security_group" "sg_publica" {
  name = var.sg_publica_name
  description = var.sg_publica_desc
  vpc_id = aws_vpc.vpc_cco.id

  ingress {
    from_port = var.ssh_port
    to_port = var.ssh_port
    protocol = var.sg_ingress_protocol
    cidr_blocks = [var.cidr_qualquer_ip]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = var.sg_egress_protocol
    cidr_blocks = [var.cidr_qualquer_ip]
  }
}

# -----------------------------------------------------------------------

# SECURITY GROUP PARA INSTANCIA PRIVADA

resource "aws_security_group" "sg_privada" {
  name = var.sg_privada_name
  description = var.sg_privada_desc
  vpc_id = aws_vpc.vpc_cco.id

  ingress {
    from_port = var.ssh_port
    to_port = var.ssh_port
    protocol = var.sg_ingress_protocol
    cidr_blocks = [aws_vpc.vpc_cco.cidr_block]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = var.sg_egress_protocol_priv
    cidr_blocks = [var.cidr_qualquer_ip]
  }
}

# -----------------------------------------------------------------------

