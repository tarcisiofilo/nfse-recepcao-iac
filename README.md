# nfse-recepcao-iac

Infraestrutura da API `nfse-recepcao`, em Terraform. O código da aplicação fica no [nfse-recepcao](https://github.com/tarcisiofilo/nfse-recepcao).

O estado mora no S3. O GitHub Actions aplica na `main` e planeja nas pull requests. Sem apply no notebook, salvo desastre.

## O que existe

- ECR `nfse-recepcao` (imagem da API).
- OIDC do GitHub e duas roles: uma só publica a imagem (`nfse-recepcao`), outra aplica este Terraform (`nfse-recepcao-iac`).
- Bucket `nfse-recepcao-iac-estado-069632764371` com o estado. O nome traz a conta porque o backend S3 não aceita variável.

- RDS Postgres 16, banco `nfse`, usuário `nfse`. Senha no Secrets Manager. Porta 5432 só do security group da API. Sem IP público. O schema `nfse_nacional` o Liquibase cria no primeiro boot da API.
- Elastic Beanstalk Docker AL2023, uma instância `t3.small`, ALB na porta 80. Só usa as subnets das AZs que oferecem esse tipo (a VPC padrão inclui `us-east-1e`, sem `t3.small`). A imagem é `${repository_url}:latest`. Scheduler desligado. Sem certificado ADN. A senha do RDS vai para as variáveis do ambiente (e para o estado do Terraform).
- Health check em `GET /nfse/totais`. O Liquibase roda nesse primeiro boot.

Sem HTTPS, fila, Lambda nem dashboard. Se o CI publicar uma imagem nova, o Beanstalk não puxa sozinho até um novo deploy.

## Como muda a infra

1. Branch e pull request neste repositório.
2. O job **Terraform** roda `plan`.
3. Merge na `main` roda `apply`.

Variáveis do repositório (Actions): `AWS_ROLE_ARN` (output `github_iac_role_arn`) e `AWS_REGION`.

## Comandos locais (só conferência)

```bash
terraform init
terraform fmt
terraform validate
terraform plan
```

O `apply` local não é o fluxo. O backend já aponta para o S3 da conta `069632764371`.
