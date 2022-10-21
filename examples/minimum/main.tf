module "ecs_service" {
  source                     = "../../"
  name                       = local.name
  cluster                    = local.cluster
  launch_type                = "EC2"
  deployment_controller_type = "EXTERNAL"
  kms_key_id                 = data.aws_kms_alias.supporting_kms.target_key_arn

  tags = {
    Name               = local.name
    Environment        = "examples"
    "user::CostCenter" = "terraform-registry"
  }
}
