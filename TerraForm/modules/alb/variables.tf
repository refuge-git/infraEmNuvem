variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "subnet_ids" {
  description = "Lista de subnets para o ALB"
  type        = list(string)
}

variable "ec2_instance_1_id" {
  description = "ID da primeira instância EC2"
  type        = string
}

variable "ec2_instance_2_id" {
  description = "ID da segunda instância EC2"
  type        = string
}