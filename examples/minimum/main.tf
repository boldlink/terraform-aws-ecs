module "ecs_service" {
  source                     = "../../"
  name                       = local.name
  cluster                    = local.cluster
  launch_type                = "EC2"
  deployment_controller_type = "EXTERNAL"

  tags = {
    Name               = local.name
    Environment        = "examples"
    "user::CostCenter" = "terraform-registry"
  }
}
