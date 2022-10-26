module "ecs_service" {
  source                     = "../../"
  name                       = local.name
  family                     = "${local.name}-task-definition"
  network_mode               = "awsvpc"
  cluster                    = local.cluster
  vpc_id                     = local.vpc_id
  task_role_policy           = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role        = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role_policy = local.task_execution_role_policy_doc
  container_definitions      = local.default_container_definitions
  kms_key_id                 = data.aws_kms_alias.supporting_kms.target_key_arn
  network_configuration = {
    subnets = local.private_subnets
  }
  service_security_group_ingress = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    Name               = local.name
    Environment        = "examples"
    "user::CostCenter" = "terraform-registry"
  }
}
