module "ecs_service" {
  #checkov:skip=CKV_AWS_290: "Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_355: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
  source                   = "../../"
  requires_compatibilities = var.requires_compatibilities
  network_mode             = var.network_mode
  name                     = "${var.name}-service"
  family                   = "${var.name}-task-definition"

  network_configuration = {
    subnets = local.private_subnets
  }

  cluster                    = local.cluster
  vpc_id                     = local.vpc_id
  task_role_policy           = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role        = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role_policy = local.task_execution_role_policy_doc
  container_definitions      = local.default_container_definitions
  retention_in_days          = var.retention_in_days
  enable_autoscaling         = var.enable_autoscaling
  scalable_dimension         = var.scalable_dimension
  service_namespace          = var.service_namespace
  kms_key_id                 = data.aws_kms_alias.supporting_kms.target_key_arn
  tags                       = local.tags
  # Load balancer sg
  lb_ingress_rules = var.lb_ingress_rules
}
