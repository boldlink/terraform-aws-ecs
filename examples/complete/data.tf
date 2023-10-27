data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

### Access Logs Bucket Policy
data "aws_iam_policy_document" "access_logs_bucket" {
  policy_id = "s3_bucket_lb_logs"

  statement {
    actions = [
      "s3:PutObject",
    ]
    effect    = "Allow"
    resources = ["arn:${local.partition}:s3:::${local.bucket}/*"]

    principals {
      identifiers = [local.service_account]
      type        = "AWS"
    }
  }

  statement {
    actions = [
      "s3:PutObject"
    ]
    effect    = "Allow"
    resources = ["arn:${local.partition}:s3:::${local.bucket}/*"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }

  statement {
    actions = [
      "s3:GetBucketAcl"
    ]
    effect    = "Allow"
    resources = ["arn:${local.partition}:s3:::${local.bucket}"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_elb_service_account" "main" {}

data "aws_vpc" "supporting" {
  filter {
    name   = "tag:Name"
    values = [var.supporting_resources_name]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["${var.supporting_resources_name}*.pub.*"]
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.public.ids)
  id       = each.value
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["${var.supporting_resources_name}*.pri.*"]
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

data "aws_ecs_cluster" "ecs" {
  cluster_name = var.supporting_resources_name
}

data "aws_kms_alias" "supporting_kms" {
  name = "alias/${var.supporting_resources_name}"
}

data "aws_iam_policy_document" "task_role_policy_doc" {
#checkov:skip=CKV_AWS_356:"Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect    = "Allow"
    resources = ["arn:${local.partition}:logs:*:*:*"]
  }
}
