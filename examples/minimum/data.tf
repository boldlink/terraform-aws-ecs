data "aws_ecs_cluster" "ecs" {
  cluster_name = local.supporting_resources_name
}

data "aws_kms_alias" "supporting_kms" {
  name = "alias/${local.supporting_resources_name}"
}
