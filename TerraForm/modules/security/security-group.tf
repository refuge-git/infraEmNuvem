# -----------------------------------------------------------------------

# SECURITY GROUP PARA INSTANCIA PUBLICA

resource "aws_security_group" "sg_publica" {
  name = var.sg_publica_name
  description = var.sg_publica_desc
  vpc_id = var.vpc_id

  ingress {
    from_port = var.ssh_port
    to_port = var.ssh_port
    protocol = var.sg_ingress_protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "RabbitMQ AMQP"
    from_port = 5672
    to_port = 5672
    protocol = "tcp"
    cidr_blocks = [var.cidr_qualquer_ip]
  }

  ingress {
    description = "RabbitMQ UI"
    from_port = 15672
    to_port = 15672
    protocol = "tcp"
    cidr_blocks = [var.cidr_qualquer_ip]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
}

# -----------------------------------------------------------------------

# SECURITY GROUP PARA INSTANCIA PRIVADA

resource "aws_security_group" "sg_privada" {
  name = var.sg_privada_name
  description = var.sg_privada_desc
  vpc_id = var.vpc_id

  ingress {
    from_port = var.ssh_port
    to_port = var.ssh_port
    protocol = var.sg_ingress_protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = var.sg_egress_protocol_priv
    cidr_blocks = [var.vpc_cidr]
  }
}

# -----------------------------------------------------------------------

