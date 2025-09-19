resource "aws_s3_bucket" "meu_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "bloco_acesso_publico_s3" {
  bucket = aws_s3_bucket.meu_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "politica_acesso_publico_bucket" {
  bucket = aws_s3_bucket.meu_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.meu_bucket.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.bloco_acesso_publico_s3]
}