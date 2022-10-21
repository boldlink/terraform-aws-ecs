module "ecs_service" {
  source                   = "../../"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  name                     = "${local.name}-service"
  family                   = "${local.name}-task-definition"

  network_configuration = {
    subnets = local.private_subnets
  }

  cluster                    = local.cluster
  vpc_id                     = local.vpc_id
  task_role_policy           = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role        = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role_policy = local.task_execution_role_policy_doc
  container_definitions      = local.default_container_definitions
  path                       = "/healthz"
  retention_in_days          = 1
  enable_autoscaling         = true
  scalable_dimension         = "ecs:service:DesiredCount"
  service_namespace          = "ecs"
  kms_key_id                 = data.aws_kms_alias.supporting_kms.target_key_arn
  service_security_group_ingress = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = local.tags
}
