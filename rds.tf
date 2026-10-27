data "aws_vpc" "padrao" {
  default = true
}

data "aws_subnets" "padrao" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.padrao.id]
  }
}

resource "aws_security_group" "api" {
  name        = "nfse-recepcao-api"
  description = "API. O Beanstalk usa este grupo. O RDS so aceita 5432 daqui."
  vpc_id      = data.aws_vpc.padrao.id
}

resource "aws_security_group" "rds" {
  name        = "nfse-recepcao-rds"
  description = "Postgres. Sem acesso da internet."
  vpc_id      = data.aws_vpc.padrao.id
}

resource "aws_vpc_security_group_ingress_rule" "rds_da_api" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.api.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  description                  = "API no Postgres"
}

resource "aws_db_subnet_group" "nfse" {
  name       = "nfse-recepcao"
  subnet_ids = data.aws_subnets.padrao.ids
}

resource "aws_db_instance" "nfse" {
  identifier     = "nfse-recepcao"
  engine         = "postgres"
  engine_version = "16"
  instance_class = var.db_instance_class

  db_name  = "nfse"
  username = "nfse"

  manage_master_user_password = true

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  db_subnet_group_name   = aws_db_subnet_group.nfse.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = false

  apply_immediately = true
}
