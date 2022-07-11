###
module "kms_key" {
  source                  = "boldlink/kms/aws"
  description             = "A test kms key for ecs"
  create_kms_alias        = true
  alias_name              = "alias/${local.cluster_name}"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  tags = {
    Name        = local.cluster_name
    Environment = "examples"
  }
}

resource "aws_cloudwatch_log_group" "cluster" {
  name = "${local.cluster_name}-log-group"
  #checkov:skip=CKV_AWS_158:Ensure that CloudWatch Log Group is encrypted by KMS"
  retention_in_days = 0
  tags = {
    Name               = local.cluster_name
    Environment        = "examples"
    "user::CostCenter" = "terraform-registry"
  }
  depends_on = [module.kms_key]
}

module "cluster" {
  source = "git::https://github.com/boldlink/terraform-aws-ecs-cluster.git?ref=1.0.1"
  name   = local.cluster_name
  configuration = {
    execute_command_configuration = {
      kms_key_id = module.kms_key.arn
      log_configuration = {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.cluster.name
        s3_bucket_encryption_enabled   = false
      }
      logging = "OVERRIDE"
    }
  }
}

module "ecs_service_ec2" {
  source = "../../"
  #checkov:skip=CKV_AWS_111:Ensure IAM policies does not allow write access without constraints"
  name                       = local.cluster_name
  requires_compatibilities   = ["EC2"]
  launch_type                = "EC2"
  deploy_service             = true
  cpu                        = 512
  memory                     = 512
  cluster                    = module.cluster.id
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
  tags = {
    Name               = local.cluster_name
    Environment        = "examples"
    "user::CostCenter" = "terraform-registry"
  }
}
