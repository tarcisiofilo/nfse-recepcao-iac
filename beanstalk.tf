data "aws_elastic_beanstalk_solution_stack" "docker" {
  most_recent = true
  name_regex  = "^64bit Amazon Linux 2023 v[0-9.]+ running Docker$"
}

data "aws_ec2_instance_type_offerings" "api" {
  filter {
    name   = "instance-type"
    values = [var.api_instance_type]
  }

  location_type = "availability-zone"
}

data "aws_subnets" "api" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.padrao.id]
  }

  filter {
    name   = "availability-zone"
    values = data.aws_ec2_instance_type_offerings.api.locations
  }
}

data "aws_secretsmanager_secret_version" "rds" {
  secret_id = aws_db_instance.nfse.master_user_secret[0].secret_arn
}

locals {
  rds_segredo = jsondecode(data.aws_secretsmanager_secret_version.rds.secret_string)

  subnets = join(",", data.aws_subnets.api.ids)

  dockerrun = jsonencode({
    AWSEBDockerrunVersion = "1"
    Image = {
      Name   = "${aws_ecr_repository.api.repository_url}:latest"
      Update = "true"
    }
    Ports = [
      {
        ContainerPort = 8080
      }
    ]
  })

  api_env = {
    SERVER_PORT                          = "8080"
    SPRING_DATASOURCE_URL                = "jdbc:postgresql://${aws_db_instance.nfse.address}:${aws_db_instance.nfse.port}/nfse"
    SPRING_DATASOURCE_USERNAME           = "nfse"
    SPRING_DATASOURCE_PASSWORD           = local.rds_segredo.password
    SPRING_PROFILES_ACTIVE               = "aws"
    SCHEDULER_RECEPCAODFESSERPRO_ENABLED = "false"
    JAVA_TOOL_OPTIONS                    = "-XX:MaxRAMPercentage=75.0"
    AWS_REGION                           = var.aws_region
    AWS_DEFAULT_REGION                   = var.aws_region
    RELATORIO_FILA                       = aws_sqs_queue.relatorios.name
    RELATORIO_BUCKET                     = aws_s3_bucket.relatorios.bucket
    RELATORIO_REGIAO                     = var.aws_region
  }
}

data "aws_iam_policy_document" "eb_service_assume" {
  statement {
    sid     = "Beanstalk"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["elasticbeanstalk.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = ["elasticbeanstalk"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.atual.account_id]
    }
  }
}

data "aws_iam_policy_document" "eb_ec2_assume" {
  statement {
    sid     = "Ec2"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eb_service" {
  name               = "nfse-recepcao-beanstalk"
  assume_role_policy = data.aws_iam_policy_document.eb_service_assume.json
}

resource "aws_iam_role_policy_attachment" "eb_service_health" {
  role       = aws_iam_role.eb_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_role_policy_attachment" "eb_service_updates" {
  role       = aws_iam_role.eb_service.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
}

resource "aws_iam_role" "eb_ec2" {
  name               = "nfse-recepcao-ec2"
  assume_role_policy = data.aws_iam_policy_document.eb_ec2_assume.json
}

resource "aws_iam_role_policy_attachment" "eb_ec2_web" {
  role       = aws_iam_role.eb_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "eb_ec2_ecr" {
  role       = aws_iam_role.eb_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "eb_ec2" {
  name = "nfse-recepcao-ec2"
  role = aws_iam_role.eb_ec2.name
}

resource "aws_security_group" "alb" {
  name        = "nfse-recepcao-alb"
  description = "ALB da API. Porta 80 da internet."
  vpc_id      = data.aws_vpc.padrao.id
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
  description       = "HTTP"
}

resource "aws_vpc_security_group_egress_rule" "alb_para_api" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.api.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  description                  = "ALB para a API"
}

resource "aws_vpc_security_group_ingress_rule" "api_do_alb" {
  security_group_id            = aws_security_group.api.id
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  description                  = "ALB"
}

resource "aws_vpc_security_group_egress_rule" "api_saida" {
  security_group_id = aws_security_group.api.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "RDS, ECR e Beanstalk"
}

data "archive_file" "api" {
  type        = "zip"
  output_path = "${path.module}/build/api-eb.zip"

  source {
    content  = local.dockerrun
    filename = "Dockerrun.aws.json"
  }
}

resource "aws_s3_object" "api_eb" {
  bucket = aws_s3_bucket.estado.id
  key    = "beanstalk/api.zip"
  source = data.archive_file.api.output_path
  etag   = data.archive_file.api.output_md5
}

resource "aws_elastic_beanstalk_application" "api" {
  name        = "nfse-recepcao"
  description = "API de recepção da NFS-e."
}

resource "aws_elastic_beanstalk_application_version" "api" {
  name        = "api-${data.archive_file.api.output_md5}"
  application = aws_elastic_beanstalk_application.api.name
  description = "Imagem :latest do ECR."
  bucket      = aws_s3_object.api_eb.bucket
  key         = aws_s3_object.api_eb.key
}

resource "aws_elastic_beanstalk_environment" "api" {
  name                   = "nfse-recepcao-api"
  application            = aws_elastic_beanstalk_application.api.name
  solution_stack_name    = data.aws_elastic_beanstalk_solution_stack.docker.name
  tier                   = "WebServer"
  version_label          = aws_elastic_beanstalk_application_version.api.name
  wait_for_ready_timeout = "25m"

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.eb_service.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_ec2.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.api.id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "DisableIMDSv1"
    value     = "true"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeType"
    value     = "gp3"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeSize"
    value     = "16"
  }

  setting {
    namespace = "aws:ec2:instances"
    name      = "InstanceTypes"
    value     = var.api_instance_type
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "1"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "1"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = data.aws_vpc.padrao.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = local.subnets
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = local.subnets
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "public"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "true"
  }

  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "SecurityGroups"
    value     = aws_security_group.alb.id
  }

  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "ManagedSecurityGroup"
    value     = aws_security_group.alb.id
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Port"
    value     = "80"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "HealthCheckPath"
    value     = "/nfse/totais"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "MatcherHTTPCode"
    value     = "200"
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }

  dynamic "setting" {
    for_each = local.api_env
    content {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = setting.key
      value     = setting.value
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.eb_service_health,
    aws_iam_role_policy_attachment.eb_service_updates,
    aws_iam_role_policy_attachment.eb_ec2_web,
    aws_iam_role_policy_attachment.eb_ec2_ecr,
    aws_db_instance.nfse,
    aws_sqs_queue.relatorios,
    aws_s3_bucket.relatorios,
    aws_iam_role_policy.eb_ec2_relatorio,
  ]

  lifecycle {
    ignore_changes = [solution_stack_name]
  }
}
