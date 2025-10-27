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
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
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
    cidr_blocks = [var.cidr_qualquer_ip]
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
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
  description      = "Permite trafego HTTP do ALB e do Frontend"
  from_port        = 8080
  to_port          = 8080
  protocol         = "tcp"
  security_groups  = [var.alb_sg_id, aws_security_group.sg_publica.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = var.sg_egress_protocol_priv
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -----------------------------------------------------------------------

# SECURITY GROUP PARA INSTANCIA MYSQL


