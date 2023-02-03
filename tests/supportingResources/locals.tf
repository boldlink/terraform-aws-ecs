locals {
  public_subnets  = [cidrsubnet(local.cidr_block, 8, 1), cidrsubnet(local.cidr_block, 8, 2), cidrsubnet(local.cidr_block, 8, 3)]
  private_subnets = [cidrsubnet(local.cidr_block, 8, 4), cidrsubnet(local.cidr_block, 8, 5), cidrsubnet(local.cidr_block, 8, 6)]
  region          = data.aws_region.current.id
  dns_suffix      = data.aws_partition.current.dns_suffix
  account_id      = data.aws_caller_identity.current.id
  partition       = data.aws_partition.current.partition
  azs             = flatten(data.aws_availability_zones.available.names)
  cidr_block      = "10.1.0.0/16"
  name            = "terraform-aws-ecs-service"

  kms_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Allow KMS Permissions to cluster",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "logs.${local.region}.${local.dns_suffix}"
        },
        "Action" : [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        "Resource" : "*"
      },

      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:${local.partition}:iam::${local.account_id}:root"
        },
        "Action" : [
          "kms:*"
        ],
        "Resource" : "*",
      }
    ]
  })
  tags ={
    Environment        = "example"
    Name               = local.name
    "user::CostCenter" = "terraform"
    department         = "DevOps"
    Project            = "Examples"
    Owner              = "Boldlink"
    InstanceScheduler  = true
    LayerName          = "cExample"
    LayerId            = "cExample"
  }
}
