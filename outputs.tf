
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

#Security_group
output "security_group_id_main" {
  value       = join("", aws_security_group.service.*.id)
  description = "The ID of service security group"
}

output "security_group_id_alb" {
  value       = join("", aws_security_group.alb.*.id)
  description = "The ID of load balancer security group"
}

output "security_group_arn_main" {
  value       = join("", aws_security_group.service.*.id)
  description = "The ARN of service security group"
}

output "security_group_arn_alb" {
  value       = join("", aws_security_group.alb.*.arn)
  description = "The ARN of load balancer security group"
}

output "security_group_vpc_id_main" {
  value       = join("", aws_security_group.service.*.vpc_id)
  description = "The VPC ID of the service security group"
}

output "security_group_owner_id_alb" {
  value       = join("", aws_security_group.service.*.owner_id)
  description = "The owner id of the service security group"
}

output "security_group_name_main" {
  value       = join("", aws_security_group.service.*.name)
  description = "Name of service security group"
}

output "security_group_name_alb" {
  value       = join("", aws_security_group.alb.*.name)
  description = "Name of load balancer security group"
}
