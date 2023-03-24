module "ecs_service" {
  source                         = "../../"
  name                           = var.name
  family                         = "${var.name}-task-definition"
  network_mode                   = var.network_mode
  cluster                        = local.cluster
  vpc_id                         = local.vpc_id
  task_role_policy               = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role            = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role_policy     = local.task_execution_role_policy_doc
  container_definitions          = local.default_container_definitions
  kms_key_id                     = data.aws_kms_alias.supporting_kms.target_key_arn
  tags                           = local.tags
  service_security_group_ingress = var.service_security_group_ingress_config
  service_security_group_egress  = var.service_security_group_egress_config

  network_configuration = {
    subnets = local.private_subnets
  }
}
