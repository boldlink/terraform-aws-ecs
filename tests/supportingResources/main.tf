module "ecs_vpc" {
  source                  = "boldlink/vpc/aws"
  version                 = "2.0.3"
  name                    = local.name
  account                 = local.account_id
  region                  = local.region
  cidr_block              = local.cidr_block
  enable_dns_hostnames    = true
  create_nat_gateway      = true
  nat_single_az           = true
  public_subnets          = local.public_subnets
  private_subnets         = local.private_subnets
  availability_zones      = local.azs
  map_public_ip_on_launch = true
  other_tags              = local.tags
}

module "kms_key" {
  source                  = "boldlink/kms/aws"
  description             = "A test kms key for ecs cluster"
  create_kms_alias        = true
  alias_name              = "alias/${local.name}"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  tags                    = local.tags
}

resource "aws_cloudwatch_log_group" "cluster" {
  #checkov:skip=CKV_AWS_158:Ensure that CloudWatch Log Group is encrypted by KMS"
  name              = "${local.name}-log-group"
  retention_in_days = 0
  tags              = local.tags
}

module "cluster" {
  source = "git::https://github.com/boldlink/terraform-aws-ecs-cluster.git?ref=1.0.1"
  name   = local.name
  configuration = {
    execute_command_configuration = {
      kms_key_id = module.kms_key.key_id
      log_configuration = {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.cluster.name
        s3_bucket_encryption_enabled   = false
      }

      logging = "OVERRIDE"
    }
  }
}
