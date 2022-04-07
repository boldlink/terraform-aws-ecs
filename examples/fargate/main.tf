provider "aws" {
  region = "eu-west-1"
}

locals {
  name      = "/aws/ecs/cloudwatch"
  cluster   = "randomcluster"
  partition = data.aws_partition.current.partition
  default_container_definitions = jsonencode(
    [
      {
        name      = "randomcontainer"
        image     = "boldlink/flaskapp"
        cpu       = 10
        memory    = 512
        essential = true
        portMappings = [
          {
            containerPort = 5000
            hostPort      = 5000
          }
        ]
      }
    ]
  )
}

resource "aws_ecs_cluster" "main" {
  name = local.cluster
  tags = {
    "Name"        = local.cluster
    "Environment" = "test"
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
module "ecs_service" {
  source                   = "./../../"
  name                     = "randomecsservice"
  environment              = "beta"
  requires_compatibilities = ["FARGATE"]
  cloudwatch_name          = local.name
  network_configuration = {
    subnets          = data.aws_subnets.ecs_subnets.ids
    assign_public_ip = true
  }

  cluster                    = aws_ecs_cluster.main.id
  vpc_id                     = data.aws_vpc.vpc.id
  task_role                  = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role        = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role_policy = data.aws_iam_policy_document.task_execution_role_policy_doc.json
  container_definitions      = local.default_container_definitions
  path                       = "/healthz"
  container_port             = 5000
  retention_in_days          = 1
  enable_autoscaling         = true
  scalable_dimension         = "ecs:service:DesiredCount"
  service_namespace          = "ecs"
}
