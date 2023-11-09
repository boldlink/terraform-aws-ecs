locals {
  public_subnet_id = [
    for i in data.aws_subnet.public : i.id
  ]
  private_subnet_id = [
    for i in data.aws_subnet.private : i.id
  ]
  public_subnets         = local.public_subnet_id
  private_subnets        = local.private_subnet_id
  vpc_id                 = data.aws_vpc.supporting.id
  cluster                = data.aws_ecs_cluster.ecs.arn
  region                 = data.aws_region.current.name
  partition              = data.aws_partition.current.partition
  dns_suffix             = data.aws_partition.current.dns_suffix
  bucket                 = "${var.name}-access-logs-bucket-boldlink"
  tags                   = merge({ "Name" = var.name }, var.tags)
  account_id             = data.aws_caller_identity.current.account_id
  elb_service_account_id = data.aws_elb_service_account.main.id
  alb_container_definitions = jsonencode(
    [
      {
        name      = var.name
        image     = var.image
        cpu       = var.cpu
        memory    = var.memory
        essential = var.essential
        portMappings = [
          {
            containerPort = var.containerport
            hostPort      = var.hostport
          }
        ]
        logConfiguration = {
          logDriver = "awslogs",
          options = {
            awslogs-group         = "/aws/ecs-service/${var.name}-alb-service",
            awslogs-region        = local.region,
            awslogs-stream-prefix = "task"
          }
        }
      }
    ]
  )
  nlb_container_definitions = jsonencode(
    [
      {
        name      = var.name
        image     = var.image
        cpu       = var.cpu
        memory    = var.memory
        essential = var.essential
        portMappings = [
          {
            containerPort = var.containerport
            hostPort      = var.hostport
          }
        ]
        logConfiguration = {
          logDriver = "awslogs",
          options = {
            awslogs-group         = "/aws/ecs-service/${var.name}-nlb-service",
            awslogs-region        = local.region,
            awslogs-stream-prefix = "task"
          }
        }
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
        Resource = ["arn:${local.partition}:logs:::log-group:${var.name}*"]
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
}
