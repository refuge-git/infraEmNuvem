variable "lambda_function_name" {
  description = "Nome da função Lambda"
  type        = string
  default     = "funcao1_terraform"
}

variable "lambda_handler" {
  description = "Handler da função Lambda"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "lambda_runtime" {
  description = "Runtime da função Lambda"
  type        = string
  default     = "python3.11"
}

variable "lambda_role_name" {
  description = "Nome da IAM Role que a Lambda vai usar"
  type        = string
  default     = "LabRole"
}

variable "lambda_layers" {
  type    = list(string)
  default = []
}