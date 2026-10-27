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

output "api_cname" {
  description = "DNS do ambiente. http://<este valor>/nfse/totais"
  value       = aws_elastic_beanstalk_environment.api.cname
}

output "api_environment_name" {
  description = "Nome do ambiente no Elastic Beanstalk."
  value       = aws_elastic_beanstalk_environment.api.name
}

output "relatorio_fila" {
  description = "Nome da fila SQS dos pedidos de Excel."
  value       = aws_sqs_queue.relatorios.name
}

output "relatorio_bucket" {
  description = "Bucket dos zips. Chave relatorios/{id}/relatorio.zip"
  value       = aws_s3_bucket.relatorios.bucket
}

output "dashboard_url" {
  description = "HTTP do dashboard no S3. CloudFront pediu verificação da conta."
  value       = "http://${aws_s3_bucket_website_configuration.dashboard.website_endpoint}"
}

output "dashboard_bucket" {
  description = "Bucket do site. Variável AWS_S3_BUCKET do nfse-dashboard."
  value       = aws_s3_bucket.dashboard.bucket
}

output "github_dashboard_role_arn" {
  description = "Role que a Actions do dashboard assume. Variável AWS_ROLE_ARN desse repositório."
  value       = aws_iam_role.github_dashboard.arn
}

output "cognito_user_pool_id" {
  description = "User Pool. Convite do primeiro usuário é no console, Create user."
  value       = aws_cognito_user_pool.login.id
}

output "cognito_client_id" {
  description = "App client público do dashboard. Sem secret."
  value       = aws_cognito_user_pool_client.dashboard.id
}

output "cognito_domain" {
  description = "Host da hosted UI. Variável VITE_COGNITO_DOMAIN do dashboard, sem https."
  value       = "${aws_cognito_user_pool_domain.login.domain}.auth.${var.aws_region}.amazoncognito.com"
}

output "cognito_issuer" {
  description = "Issuer JWT. Variável COGNITO_ISSUER da API."
  value       = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.login.id}"
}
