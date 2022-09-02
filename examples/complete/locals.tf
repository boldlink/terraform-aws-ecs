locals {
  cidr_block      = "172.16.0.0/16"
  tag_env         = "Dev"
  public_subnets  = cidrsubnets(local.cidr_block, 8, 8, 8)
  azs             = flatten(data.aws_availability_zones.available.names)
  name            = "complete-example"
  partition       = data.aws_partition.current.partition
  bucket          = "${local.name}-access-logs-bucket0"
  service_account = data.aws_elb_service_account.main.arn
  tags = {
    Name               = local.name
    Environment        = "examples"
    "user::CostCenter" = "terraform-registry"
  }
  default_container_definitions = jsonencode(
    [
      {
        name      = local.name
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
