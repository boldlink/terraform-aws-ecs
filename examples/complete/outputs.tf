output "alb_service_url" {
  value       = "https://${module.ecs_service_alb.lb_dns_name}/v1/api"
  description = "The task definition arn"
}

output "nlb_service_url" {
  value       = "https://${module.ecs_service_nlb.lb_dns_name}:5000/v1/api"
  description = "The task definition arn"
}
