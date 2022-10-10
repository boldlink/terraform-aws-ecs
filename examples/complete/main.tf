module "access_logs_bucket" {
  source        = "boldlink/s3/aws"
  version       = "2.2.0"
  bucket        = local.bucket
  force_destroy = true
  bucket_policy = data.aws_iam_policy_document.access_logs_bucket.json
  tags          = local.tags
}

module "ecs_service_lb" {
  source = "../../"
  #checkov:skip=CKV_AWS_111:Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_91:Ensure IAM policies does not allow write access without constraints"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  name                     = "${local.name}-service"
  family                   = "${local.name}-task-definition"
  network_configuration = {
    subnets          = local.public_subnets
    assign_public_ip = true
  }
  alb_subnets                = local.public_subnets
  cluster                    = local.cluster
  vpc_id                     = local.vpc_id
  task_role_policy           = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role        = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role_policy = data.aws_iam_policy_document.task_execution_role_policy_doc.json
  container_definitions      = local.default_container_definitions
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

  service_security_group_ingress = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [local.vpc_cidr]
    }
  ]

  tags = local.tags
}
