locals {
  subnet_id = [
    for i in data.aws_subnet.public : i.id
  ]

  name                      = "complete-ecs-example"
  public_subnets            = local.subnet_id
  supporting_resources_name = "terraform-aws-ecs-service"
  vpc_id                    = data.aws_vpc.supporting.id
  vpc_cidr                  = data.aws_vpc.supporting.cidr_block
  cluster                   = data.aws_ecs_cluster.ecs.arn
  partition                 = data.aws_partition.current.partition
  bucket                    = "${local.name}-access-logs-bucket"
  service_account           = data.aws_elb_service_account.main.arn

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

  tags = {
    Name               = local.name
    Environment        = "examples"
    "user::CostCenter" = "terraform-registry"
  }
}
