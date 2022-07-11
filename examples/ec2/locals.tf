locals {
  name         = "/aws/ecs-service/cloudwatch"
  cluster_name = "ecs-ec2-example"
  partition    = data.aws_partition.current.partition
  default_container_definitions = jsonencode(
    [
      {
        name      = "randomcontainer2"
        image     = "boldlink/flaskapp"
        cpu       = 128
        memory    = 256
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
