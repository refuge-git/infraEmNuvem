# Empacota o código Python em um ZIP
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

# Usa o LabRole já existente (caso precise, pode criar um IAM Role novo também)
data "aws_iam_role" "lab_role" {
  name = var.lambda_role_name
}

# Criação da Lambda
resource "aws_lambda_function" "this" {
  function_name    = var.lambda_function_name
  handler          = var.lambda_handler
  runtime          = var.lambda_runtime
  role             = data.aws_iam_role.lab_role.arn
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  layers = var.lambda_layers
}


# Output no módulo Lambda (caso ainda não exista)
output "lambda_function_arn" {
  value = aws_lambda_function.this.arn
}
