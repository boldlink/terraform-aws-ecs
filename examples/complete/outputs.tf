output "alb_dns_name" {
  value       = [module.ecs_service_alb.alb_dns_name]
  description = "The task definition arn"
}

output "alb_arn" {
  value       = [module.ecs_service_alb.lb_arn]
  description = "The load balancer arn/id"
}

