module "ecs_service" {
  #checkov:skip=CKV_AWS_290: "Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_355: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
  source                            = "../../"
  name                              = var.name
  family                            = "${var.name}"
  network_mode                      = var.network_mode
  cluster                           = local.cluster
  vpc_id                            = local.vpc_id
  task_assume_role_policy           = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role_policy        = local.task_execution_role_policy_doc
  container_definitions             = local.default_container_definitions
  kms_key_id                        = data.aws_kms_alias.supporting_kms.target_key_arn
  tags                              = local.tags
  service_ingress_rules             = var.service_ingress_rules

  network_configuration = {
    subnets = local.private_subnets
  }
}
