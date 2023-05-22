module "access_logs_bucket" {
  source        = "boldlink/s3/aws"
  version       = "2.2.0"
  bucket        = local.bucket
  force_destroy = var.force_destroy
  bucket_policy = data.aws_iam_policy_document.access_logs_bucket.json
  tags          = local.tags
}

module "ecs_service_lb" {
  #checkov:skip=CKV_AWS_150: "Ensure that Load Balancer has deletion protection enabled"
  source                   = "../../"
  requires_compatibilities = var.requires_compatibilities
  network_mode             = var.network_mode
  name                     = "${var.name}-service"
  family                   = "${var.name}-task-definition"
  enable_execute_command   = true
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
  path                       = var.path
  tags                       = local.tags
  load_balancer = {
    container_name = var.name
    container_port = var.containerport
  }

  access_logs = {
    bucket  = module.access_logs_bucket.id
    enabled = var.access_logs_enabled
  }

  retention_in_days          = var.retention_in_days
  drop_invalid_header_fields = var.drop_invalid_header_fields
  tg_port                    = var.tg_port
  create_load_balancer       = var.create_load_balancer
  enable_autoscaling         = var.enable_autoscaling
  scalable_dimension         = var.scalable_dimension
  service_namespace          = var.service_namespace

  # Load balancer sg
  lb_security_group_ingress = var.lb_security_group_ingress_config
  lb_security_group_egress  = var.lb_security_group_egress_config

  # Service load balancer sg
  service_security_group_egress = var.service_sg_egress_config
  service_security_group_ingress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [local.vpc_cidr]
    }
  ]
}
