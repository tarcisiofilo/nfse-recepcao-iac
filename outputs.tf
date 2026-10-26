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
