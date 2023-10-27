output "task_definition_arn" {
  value       = [module.ecs_service_lb.task_definition_arn]
  description = "The task definition arn"
}

output "lb_arn" {
  value       = [module.ecs_service_lb.lb_arn]
  description = "The load balancer arn/id"
}

output "lb_sg_id" {
  value       = [module.ecs_service_lb.lb_sg_id]
  description = "The ID of the load balancer security group"
}

output "service_sg_id" {
  value       = [module.ecs_service_lb.service_sg_id]
  description = "The ID of the service security group"
}
