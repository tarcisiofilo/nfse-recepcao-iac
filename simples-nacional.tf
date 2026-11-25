data "aws_iam_policy_document" "eb_ec2_simples_nacional" {
  statement {
    sid    = "S3SimplesNacional"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.simples_nacional.arn}/simples-nacional/*"]
  }
}

resource "aws_iam_role_policy" "eb_ec2_simples_nacional" {
  name   = "simples-nacional"
  role   = aws_iam_role.eb_ec2.id
  policy = data.aws_iam_policy_document.eb_ec2_simples_nacional.json
}

resource "aws_s3_bucket" "simples_nacional" {
  bucket = "nfse-simples-nacional-${data.aws_caller_identity.atual.account_id}"
}

resource "aws_s3_bucket_versioning" "simples_nacional" {
  bucket = aws_s3_bucket.simples_nacional.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "simples_nacional" {
  bucket = aws_s3_bucket.simples_nacional.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "simples_nacional" {
  bucket                  = aws_s3_bucket.simples_nacional.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
