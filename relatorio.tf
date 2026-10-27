data "aws_iam_policy_document" "eb_ec2_relatorio" {
  statement {
    sid    = "SqsRelatorio"
    effect = "Allow"
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
    ]
    resources = [aws_sqs_queue.relatorios.arn]
  }

  statement {
    sid    = "S3Relatorio"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = ["${aws_s3_bucket.relatorios.arn}/relatorios/*"]
  }
}

resource "aws_iam_role_policy" "eb_ec2_relatorio" {
  name   = "relatorio"
  role   = aws_iam_role.eb_ec2.id
  policy = data.aws_iam_policy_document.eb_ec2_relatorio.json
}

resource "aws_sqs_queue" "relatorios" {
  name                       = "nfse-relatorios"
  visibility_timeout_seconds = 900
  receive_wait_time_seconds  = 5
  message_retention_seconds  = 86400
}

resource "aws_s3_bucket" "relatorios" {
  bucket        = "nfse-recepcao-relatorios-${data.aws_caller_identity.atual.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "relatorios" {
  bucket = aws_s3_bucket.relatorios.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "relatorios" {
  bucket = aws_s3_bucket.relatorios.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "relatorios" {
  bucket                  = aws_s3_bucket.relatorios.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "relatorios" {
  bucket = aws_s3_bucket.relatorios.id

  rule {
    id     = "expira"
    status = "Enabled"

    filter {
      prefix = "relatorios/"
    }

    expiration {
      days = 2
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "relatorios" {
  bucket = aws_s3_bucket.relatorios.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = [
      "http://localhost:5173",
      "http://127.0.0.1:5173",
    ]
    expose_headers  = ["Content-Length", "Content-Type"]
    max_age_seconds = 3000
  }
}
