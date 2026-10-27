# nfse-recepcao-iac

Infraestrutura da API `nfse-recepcao`, em Terraform. O código da aplicação fica no [nfse-recepcao](https://github.com/tarcisiofilo/nfse-recepcao).

O estado mora no S3. O GitHub Actions aplica na `main` e planeja nas pull requests. Sem apply no notebook, salvo desastre.

## O que existe

- ECR `nfse-recepcao` (imagem da API).
- OIDC do GitHub e duas roles: uma só publica a imagem (`nfse-recepcao`), outra aplica este Terraform (`nfse-recepcao-iac`).
- Bucket `nfse-recepcao-iac-estado-069632764371` com o estado. O nome traz a conta porque o backend S3 não aceita variável.

Sem Beanstalk, RDS, fila e Lambda.

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
