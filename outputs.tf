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

output "github_iac_role_arn" {
  description = "Role que a Actions do nfse-recepcao-iac assume. Variável AWS_ROLE_ARN desse repositório."
  value       = aws_iam_role.github_iac.arn
}

output "estado_bucket" {
  description = "Bucket do estado do Terraform."
  value       = aws_s3_bucket.estado.bucket
}

output "rds_address" {
  description = "Host do Postgres. A API usa na SPRING_DATASOURCE_URL."
  value       = aws_db_instance.nfse.address
}

output "rds_port" {
  description = "Porta do Postgres."
  value       = aws_db_instance.nfse.port
}

output "rds_secret_arn" {
  description = "Segredo com o usuário e a senha. A API não lê o Git."
  value       = aws_db_instance.nfse.master_user_secret[0].secret_arn
}

output "security_group_api_id" {
  description = "Security group da API. O Beanstalk entra nele."
  value       = aws_security_group.api.id
}
