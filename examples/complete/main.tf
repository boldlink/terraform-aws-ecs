module "access_logs_bucket" {
  source        = "boldlink/s3/aws"
  version       = "2.3.1"
  bucket        = local.bucket
  force_destroy = var.force_destroy
  sse_sse_algorithm = "AES256" # For production use aws:kms with your CMK and the proper key policy allowing ebs account to use the cmk
  bucket_acl    = {
    acl = "log-delivery-write"
  }
  bucket_policy = data.aws_iam_policy_document.access_logs_bucket.json
  tags          = local.tags
}

module "ecs_service_alb" {
  #checkov:skip=CKV_AWS_150: "Ensure that Load Balancer has deletion protection enabled"
  #checkov:skip=CKV_AWS_290: "Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_355: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
  source                   = "../../"
  requires_compatibilities = var.requires_compatibilities
  network_mode             = var.network_mode
  name                     = "${var.name}-alb-service"
  family                   = "${var.name}-alb-task-definition"
  enable_execute_command   = var.enable_execute_command
  idle_timeout             = 120
  network_configuration = {
    subnets          = local.private_subnets
    assign_public_ip = true
  }

  triggers = {
    redeployment = timestamp()
  }

  alb_subnets                       = local.public_subnets
  cluster                           = local.cluster
  vpc_id                            = local.vpc_id
  task_assume_role_policy           = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_role_policy                  = data.aws_iam_policy_document.task_role_policy_doc.json
  task_execution_assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role_policy        = local.task_execution_role_policy_doc
  container_definitions             = local.alb_container_definitions
  kms_key_id                        = data.aws_kms_alias.supporting_kms.target_key_arn
  force_new_deployment              = var.force_new_deployment
  path                              = var.path
  tasks_minimum_healthy_percent     = 80
  tasks_maximum_percent             = 150
  tags                              = local.tags

  load_balancer = {
    container_name = var.name
    container_port = var.containerport
  }

  access_logs = {
    bucket  = module.access_logs_bucket.id
    enabled = var.access_logs_enabled
    prefix  = "alb"
  }

  retention_in_days          = var.retention_in_days
  drop_invalid_header_fields = var.drop_invalid_header_fields
  tg_port                    = var.tg_port
  create_load_balancer       = var.create_load_balancer
  enable_autoscaling         = var.enable_autoscaling
  scalable_dimension         = var.scalable_dimension
  service_namespace          = var.service_namespace

  # Load balancer sg
  lb_ingress_rules = var.alb_ingress_rules
  depends_on       = [module.access_logs_bucket]
}

module "ecs_service_nlb" {
  #checkov:skip=CKV_AWS_150: "Ensure that Load Balancer has deletion protection enabled"
  #checkov:skip=CKV_AWS_290: "Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_355: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
  source                   = "../../"
  requires_compatibilities = var.requires_compatibilities
  network_mode             = var.network_mode
  name                     = "${var.name}-nlb-service"
  family                   = "${var.name}-nlb-task-definition"
  enable_execute_command   = var.enable_execute_command
  load_balancer_type       = "network"
  network_configuration = {
    subnets          = local.private_subnets
    assign_public_ip = true
  }
  alb_subnets                       = local.public_subnets
  cluster                           = local.cluster
  vpc_id                            = local.vpc_id
  task_assume_role_policy           = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_role_policy                  = data.aws_iam_policy_document.task_role_policy_doc.json
  task_execution_assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role_policy        = local.task_execution_role_policy_doc
  container_definitions             = local.nlb_container_definitions
  kms_key_id                        = data.aws_kms_alias.supporting_kms.target_key_arn
  force_new_deployment              = var.force_new_deployment
  path                              = var.path
  tasks_minimum_healthy_percent     = 80
  tasks_maximum_percent             = 150
  tags                              = local.tags

  load_balancer = {
    container_name = var.name
    container_port = var.containerport
  }
  access_logs = {
    bucket  = module.access_logs_bucket.id
    enabled = var.access_logs_enabled
    prefix  = "nlb"
  }

  retention_in_days          = var.retention_in_days
  drop_invalid_header_fields = var.drop_invalid_header_fields
  tg_port                    = var.tg_port
  tg_protocol                = "TCP"
  create_load_balancer       = var.create_load_balancer
  enable_autoscaling         = var.enable_autoscaling
  scalable_dimension         = var.scalable_dimension
  service_namespace          = var.service_namespace

  # Load balancer sg
  lb_ingress_rules = var.nlb_ingress_rules
  depends_on       = [module.access_logs_bucket]
}

module "log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket_prefix = "logs-${local.region}-${local.account_id}"
  acl           = "log-delivery-write"

  # For example only
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_elb_log_delivery_policy = true # Required for ALB logs
  attach_lb_log_delivery_policy  = true # Required for ALB/NLB logs

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  tags = local.tags
}