variable "aws_region" {
  type        = string
  description = "Região da AWS. Sem conta nem ID hardcoded."
  default     = "us-east-1"
}

variable "repository_name" {
  type        = string
  description = "Nome do repositório ECR da API."
  default     = "nfse-recepcao"
}

variable "github_owner" {
  type        = string
  description = "Dono do repositório da API no GitHub."
  default     = "tarcisiofilo"
}

variable "github_owner_id" {
  type        = string
  description = "ID numérico do dono. O GitHub manda isso no subject do OIDC."
  default     = "29897751"
}

variable "github_repository" {
  type        = string
  description = "Repositório da API no GitHub."
  default     = "nfse-recepcao"
}

variable "github_repository_id" {
  type        = string
  description = "ID numérico do repositório da API."
  default     = "1434495499"
}

variable "github_branch" {
  type        = string
  description = "Branch que pode publicar a imagem e aplicar a infra."
  default     = "main"
}

variable "github_iac_repository" {
  type        = string
  description = "Repositório Terraform no GitHub."
  default     = "nfse-recepcao-iac"
}

variable "github_iac_repository_id" {
  type        = string
  description = "ID numérico do repositório Terraform."
  default     = "1434723467"
}
