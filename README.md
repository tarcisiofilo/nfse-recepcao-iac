# nfse-recepcao-iac

Infraestrutura da API `nfse-recepcao`, em Terraform. O código da aplicação fica no [nfse-recepcao](https://github.com/tarcisiofilo/nfse-recepcao).

Por agora só existe o ECR. Sem Beanstalk, RDS, fila, Lambda e sem login OIDC da Actions.

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

O passo seguinte é o OIDC entre o GitHub Actions do `nfse-recepcao` e esta conta, para publicar a imagem no ECR.
