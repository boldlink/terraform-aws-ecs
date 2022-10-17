locals {
  name                      = "minimum-example"
  cluster                   = data.aws_ecs_cluster.ecs.arn
  supporting_resources_name = "terraform-aws-ecs-service"
}
