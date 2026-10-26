# nfse-recepcao-iac

Infraestrutura da API `nfse-recepcao`, em Terraform. O código da aplicação fica no [nfse-recepcao](https://github.com/tarcisiofilo/nfse-recepcao).

Existe o ECR e o login OIDC da Actions. Sem Beanstalk, RDS, fila e Lambda.

## ECR

O repositório `nfse-recepcao` guarda as imagens da API. O scan roda no push. Imagens sem tag saem em 14 dias. A tag pode ser reescrita (`MUTABLE`) para o primeiro deploy.

A região padrão é `us-east-1`. Troque em `terraform.tfvars` se precisar. Não versionar `*.tfvars`.

```hcl
aws_region      = "us-east-1"
repository_name = "nfse-recepcao"
```

## Comandos

Não aplicar na AWS sem combinar. O estado ainda é local.

```bash
terraform init
terraform fmt
terraform validate
terraform plan
```

O `apply` cria o registro na conta configurada no AWS CLI. Sem conta, o `plan` também falha.

## OIDC

A role `github-nfse-recepcao-ecr` só aceita o GitHub Actions da `main` de `tarcisiofilo/nfse-recepcao`. O repositório da API nasceu depois de 15 de julho de 2026, então o subject leva os IDs imutáveis (`tarcisiofilo@29897751/nfse-recepcao@1434495499`). Sem access key.

Depois do `apply`, copie os outputs `github_role_arn`, `repository_url` e `aws_region` para as variáveis do repositório da API:

| Variável no GitHub | Output |
| --- | --- |
| `AWS_ROLE_ARN` | `github_role_arn` |
| `AWS_ECR_REPOSITORY` | `repository_url` |
| `AWS_REGION` | `aws_region` |

Sem essas variáveis, o job de publicar não roda. O passo seguinte é hospedar a API (Elastic Beanstalk com Docker).
