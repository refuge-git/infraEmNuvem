# -----------------------------------------------------------------------

# SECURITY GROUP PARA INSTANCIA PUBLICA

resource "aws_security_group" "sg_publica" {
  name = "sg_publica"
  description = "Permite acesso SSH de qualquer IP"
  vpc_id = aws_vpc.vpc_cco.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.cidr_qualquer_ip]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = 0
    cidr_blocks = [var.cidr_qualquer_ip]
  }
}

# -----------------------------------------------------------------------

# SECURITY GROUP PARA INSTANCIA PRIVADA

resource "aws_security_group" "sg_privada" {
  name = "sg_privada"
  description = "Permite acesso SSH apenas da mesma VPC"
  vpc_id = aws_vpc.vpc_cco.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [aws_vpc.vpc_cco.cidr_block]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.cidr_qualquer_ip]
  }
}

# -----------------------------------------------------------------------

