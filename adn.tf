data "aws_iam_policy_document" "eb_ec2_adn" {
  statement {
    sid    = "SegredoAdnCliente"
    effect = "Allow"
    actions = [
      "secretsmanager:CreateSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
    ]
    resources = [
      "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.atual.account_id}:secret:nfse/cliente/*",
    ]
  }
}

resource "aws_iam_role_policy" "eb_ec2_adn" {
  name   = "adn-cliente"
  role   = aws_iam_role.eb_ec2.id
  policy = data.aws_iam_policy_document.eb_ec2_adn.json
}
