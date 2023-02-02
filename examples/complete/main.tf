module "access_logs_bucket" {
  source        = "boldlink/s3/aws"
  version       = "2.2.0"
  bucket        = local.bucket
  force_destroy = true
  bucket_policy = data.aws_iam_policy_document.access_logs_bucket.json
  tags          = local.tags
}

module "ecs_service_lb" {
  source                   = "../../"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  name                     = "${local.name}-service"
  family                   = "${local.name}-task-definition"

  network_configuration = {
    subnets = local.private_subnets
  }

  alb_subnets                = local.public_subnets
  cluster                    = local.cluster
  vpc_id                     = local.vpc_id
  task_role_policy           = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role        = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role_policy = local.task_execution_role_policy_doc
  container_definitions      = local.default_container_definitions
  kms_key_id                 = data.aws_kms_alias.supporting_kms.target_key_arn
  path                       = "/healthz"
  enable_deletion_protection = true
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

  lb_security_group_egress = [
    {
      from_port = 0
      to_port   = 0
      protocol  = "-1"
    }
  ]

  service_security_group_ingress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [local.vpc_cidr]
    }
  ]

  service_security_group_egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = local.tags
}
