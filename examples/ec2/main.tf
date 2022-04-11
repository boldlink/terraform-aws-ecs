provider "aws" {
  region = "eu-west-1"
}

data "aws_ecs_cluster" "ecs_ec2" {
  cluster_name = "samplecluster"
}

locals {
  name      = "/aws/ecs-service/cloudwatch"
  partition = data.aws_partition.current.partition
  default_container_definitions = jsonencode(
    [
      {
        name      = "randomcontainer2"
        image     = "boldlink/flaskapp"
        cpu       = 128
        memory    = 256
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

module "ecs_service_ec2" {
  source                     = "./../../"
  name                       = "randomecsservice-ec2"
  requires_compatibilities   = ["EC2"]
  launch_type                = "EC2"
  environment                = "beta"
  cpu                        = 512
  memory                     = 512
  cloudwatch_name            = local.name
  cluster                    = data.aws_ecs_cluster.ecs_ec2.id
  task_role                  = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role        = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role_policy = data.aws_iam_policy_document.task_execution_role_policy_doc.json
  container_definitions      = local.default_container_definitions
  desired_count              = 1
  create_load_balancer       = false
  retention_in_days          = 1
  network_mode               = "bridge"
  enable_autoscaling         = true
  scalable_dimension         = "ecs:service:DesiredCount"
  service_namespace          = "ecs"
}
