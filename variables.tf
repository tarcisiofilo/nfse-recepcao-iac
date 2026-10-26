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
