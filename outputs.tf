output "repository_url" {
  description = "URL do ECR para o docker push da API."
  value       = aws_ecr_repository.api.repository_url
}

output "repository_arn" {
  description = "ARN do repositório ECR."
  value       = aws_ecr_repository.api.arn
}

output "aws_region" {
  description = "Região em que o ECR foi declarado."
  value       = var.aws_region
}

output "github_role_arn" {
  description = "Role que a Actions assume. Vai na variável AWS_ROLE_ARN do repositório da API."
  value       = aws_iam_role.github_ecr.arn
}

output "github_oidc_sub" {
  description = "Subject que a role aceita. Só a main do nfse-recepcao."
  value       = local.github_oidc_sub
}
