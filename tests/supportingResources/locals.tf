locals {
  public_subnets  = [cidrsubnet(local.cidr_block, 8, 1), cidrsubnet(local.cidr_block, 8, 2), cidrsubnet(local.cidr_block, 8, 3)]
  private_subnets = [cidrsubnet(local.cidr_block, 8, 4), cidrsubnet(local.cidr_block, 8, 5), cidrsubnet(local.cidr_block, 8, 6)]
  region          = data.aws_region.current.id
  account_id      = data.aws_caller_identity.current.id
  azs             = flatten(data.aws_availability_zones.available.names)
  cidr_block      = "10.1.0.0/16"
  name            = "terraform-aws-ecs-service"
  tags = {
    Environment        = "examples"
    "user::CostCenter" = "terraform-registry"
  }
}
