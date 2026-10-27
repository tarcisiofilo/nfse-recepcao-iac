locals {
  github_iac_oidc_main = "repo:${var.github_owner}@${var.github_owner_id}/${var.github_iac_repository}@${var.github_iac_repository_id}:ref:refs/heads/${var.github_branch}"
  github_iac_oidc_pr   = "repo:${var.github_owner}@${var.github_owner_id}/${var.github_iac_repository}@${var.github_iac_repository_id}:pull_request"
}

data "aws_iam_policy_document" "github_iac_assume" {
  statement {
    sid     = "GitHubActionsIac"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        local.github_iac_oidc_main,
        local.github_iac_oidc_pr,
      ]
    }
  }
}

resource "aws_iam_role" "github_iac" {
  name               = "github-${var.github_iac_repository}"
  assume_role_policy = data.aws_iam_policy_document.github_iac_assume.json
}

resource "aws_iam_role_policy_attachment" "github_iac" {
  role       = aws_iam_role.github_iac.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
