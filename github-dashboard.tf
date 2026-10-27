locals {
  github_dashboard_oidc_sub = "repo:${var.github_owner}@${var.github_owner_id}/${var.github_dashboard_repository}@${var.github_dashboard_repository_id}:ref:refs/heads/${var.github_branch}"
}

data "aws_iam_policy_document" "github_dashboard_assume" {
  statement {
    sid     = "GitHubActionsDashboard"
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
      values   = [local.github_dashboard_oidc_sub]
    }
  }
}

data "aws_iam_policy_document" "github_dashboard" {
  statement {
    sid    = "S3Lista"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [aws_s3_bucket.dashboard.arn]
  }

  statement {
    sid    = "S3Objetos"
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = ["${aws_s3_bucket.dashboard.arn}/*"]
  }
}

resource "aws_iam_role" "github_dashboard" {
  name               = "github-${var.github_dashboard_repository}"
  assume_role_policy = data.aws_iam_policy_document.github_dashboard_assume.json
}

resource "aws_iam_role_policy" "github_dashboard" {
  name   = "dashboard-s3"
  role   = aws_iam_role.github_dashboard.id
  policy = data.aws_iam_policy_document.github_dashboard.json
}
