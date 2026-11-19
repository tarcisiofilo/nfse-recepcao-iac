data "aws_iam_policy_document" "eb_ec2_rds" {
  statement {
    sid    = "SegredoMasterRds"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      aws_db_instance.nfse.master_user_secret[0].secret_arn,
    ]
  }
}

resource "aws_iam_role_policy" "eb_ec2_rds" {
  name   = "rds-master"
  role   = aws_iam_role.eb_ec2.id
  policy = data.aws_iam_policy_document.eb_ec2_rds.json
}
