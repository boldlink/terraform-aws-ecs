module "cluster" {
  source = "git::https://github.com/boldlink/terraform-aws-ecs-cluster.git?ref=1.0.1"
  name   = local.name
  configuration = {
    execute_command_configuration = {
      log_configuration = {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.cluster.name
        s3_bucket_encryption_enabled   = false
      }
      logging = "OVERRIDE"
    }
  }
}

resource "aws_cloudwatch_log_group" "cluster" {
  name              = "${local.name}-log-group"
  retention_in_days = 0
  tags = {
    Name               = local.name
    Environment        = "examples"
    "user::CostCenter" = "terraform-registry"
  }
}

module "ecs_service" {
  source = "../../"
  #checkov:skip=CKV_AWS_158:Ensure that CloudWatch Log Group is encrypted by KMS"
  name                       = local.name
  cluster                    = module.cluster.id
  launch_type                = "EC2"
  deployment_controller_type = "EXTERNAL"

  tags = {
    Name               = local.name
    Environment        = "examples"
    "user::CostCenter" = "terraform-registry"
  }
}
