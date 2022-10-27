locals {
  private_subnet_id = [
    for i in data.aws_subnet.private : i.id
  ]

  name                      = "fargate-ecs-service-example"
  private_subnets           = local.private_subnet_id
  supporting_resources_name = "terraform-aws-ecs-service"
  vpc_id                    = data.aws_vpc.supporting.id
  cluster                   = data.aws_ecs_cluster.ecs.arn
  partition                 = data.aws_partition.current.partition
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

  task_execution_role_policy_doc = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [{
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = ["arn:${local.partition}:logs:::log-group:${local.name}"]
        },
        {
          Effect = "Allow"
          Action = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]

          Resource = ["*"]
        }
    ] }
  )

  tags = {
    Name               = local.name
    Environment        = "examples"
    "user::CostCenter" = "terraform-registry"
  }
}
