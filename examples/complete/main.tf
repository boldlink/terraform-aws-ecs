#####
module "vpc" {
  source               = "git::https://github.com/boldlink/terraform-aws-vpc.git?ref=2.0.3"
  cidr_block           = local.cidr_block
  name                 = local.name
  enable_dns_support   = true
  enable_dns_hostnames = true
  account              = data.aws_caller_identity.current.account_id
  region               = data.aws_region.current.name

  ## public Subnets
  public_subnets          = local.public_subnets
  availability_zones      = local.azs
  map_public_ip_on_launch = true
  tag_env                 = local.tag_env
}

module "kms_key" {
  source                  = "boldlink/kms/aws"
  description             = "A test kms key for ecs cluster"
  create_kms_alias        = true
  alias_name              = "alias/${local.name}"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  tags                    = local.tags
}

module "access_logs_bucket" {
  source        = "boldlink/s3/aws"
  version       = "2.2.0"
  bucket        = local.bucket
  force_destroy = true
  bucket_policy = data.aws_iam_policy_document.access_logs_bucket.json
  tags          = local.tags
}

resource "aws_cloudwatch_log_group" "cluster" {
  #checkov:skip=CKV_AWS_158:Ensure that CloudWatch Log Group is encrypted by KMS"
  name              = "${local.name}-log-group"
  retention_in_days = 0
  tags              = local.tags
}

module "cluster" {
  source = "git::https://github.com/boldlink/terraform-aws-ecs-cluster.git?ref=1.0.1"
  name   = local.name
  configuration = {
    execute_command_configuration = {
      kms_key_id = module.kms_key.key_id
      log_configuration = {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.cluster.name
        s3_bucket_encryption_enabled   = false
      }
      logging = "OVERRIDE"
    }
  }
}

module "ecs_service_lb" {
  source = "../../"
  #checkov:skip=CKV_AWS_111:Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_91:Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_103:Ensure IAM policies does not allow write access without constraints"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  name                     = "${local.name}-service"
  family                   = "${local.name}-task-definition"
  network_configuration = {
    subnets          = flatten(module.vpc.public_subnet_id)
    assign_public_ip = true
  }
  alb_subnets                = flatten(module.vpc.public_subnet_id)
  cluster                    = module.cluster.id
  vpc_id                     = module.vpc.id
  task_role_policy           = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role        = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role_policy = data.aws_iam_policy_document.task_execution_role_policy_doc.json
  container_definitions      = local.default_container_definitions
  path                       = "/healthz"
  enable_deletion_protection = false
  load_balancer = {
    container_name = local.name
    container_port = 5000
  }

  access_logs = {
    bucket  = module.access_logs_bucket.id
    enabled = true
  }

  retention_in_days          = 1
  drop_invalid_header_fields = true
  tg_port                    = 5000
  create_load_balancer       = true
  enable_autoscaling         = true
  scalable_dimension         = "ecs:service:DesiredCount"
  service_namespace          = "ecs"
  lb_security_group_ingress = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  service_security_group_ingress = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [local.cidr_block]
    }
  ]

  tags = local.tags
}
