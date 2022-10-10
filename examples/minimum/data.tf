data "aws_ecs_cluster" "ecs" {
  cluster_name = local.supporting_resources_name
}
