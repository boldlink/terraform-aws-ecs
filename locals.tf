locals {
  create_task_definition = var.deployment_controller_type != "EXTERNAL" && var.create_task_definition ? true : false
  create_lb_sg           = var.create_load_balancer && length(var.lb_security_group_ingress) > 0 ? true : false
  create_svc_sg          = length(var.service_security_group_ingress) > 0 ? true : false
  region                 = data.aws_region.current.name
  partition              = data.aws_partition.current.partition
  account_id             = data.aws_caller_identity.current.account_id
  dns_suffix             = data.aws_partition.current.dns_suffix
  lb_dns_name            = var.create_load_balancer == false ? "empty" : aws_lb.main[0].dns_name
  kms_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Allow KMS Permissions to Service",
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
}
