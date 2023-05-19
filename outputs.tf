
output "iam_role_arn_role" {
  value       = [aws_iam_role.task_role.*.arn]
  description = "The ARN of IAM task role"
}

output "iam_role_id_role" {
  value       = [aws_iam_role.task_role.*.id]
  description = "ID of IAM task role"
}

output "iam_role_name_role" {
  value       = [aws_iam_role.task_role.*.name]
  description = "Name of IAM task role"
}

output "iam_role_create_date_role" {
  value       = [aws_iam_role.task_role.*.create_date]
  description = "Creation date of IAM task role"
}

output "iam_role_unique_id_role" {
  value       = [aws_iam_role.task_role.*.unique_id]
  description = "Unique ID of IAM task role "
}

# Cloudwatch Group
output "cloudwatch_log_group_arn" {
  value       = aws_cloudwatch_log_group.main.arn
  description = "ARN of cloudwatch log group"
}

output "lb_dns_name" {
  # count       = var.create_load_balancer ? 1 : 0
  value       = local.lb_dns_name
  description = "DNS name of load balancer"
}

output "lb_dns_zone_id" {
  # count       = var.create_load_balancer ? 1 : 0
  value       = local.lb_dns_zone_id
  description = "DNS zone id of load balancer"
}
