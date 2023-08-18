variable "name" {
  type        = string
  description = "Name of the stack"
  default     = "fargate-ecs-example"
}

variable "supporting_resources_name" {
  type        = string
  description = "Name of the supporting resources stack"
  default     = "terraform-aws-ecs-service"
}

variable "image" {
  type        = string
  description = "Name of image to pull from dockerhub"
  default     = "boldlink/flaskapp:latest"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the resources"
  default = {
    Environment        = "example"
    "user::CostCenter" = "terraform"
    Department         = "DevOps"
    Project            = "Examples"
    InstanceScheduler  = true
    Owner              = "Boldlink"
    LayerName          = "cExample"
    LayerId            = "cExample"
  }
}

variable "cpu" {
  type        = number
  description = "The number of cpu units to allocate"
  default     = 10
}

variable "memory" {
  type        = number
  description = "The size of memory to allocate in MiBs"
  default     = 512
}

variable "essential" {
  type        = bool
  description = "Whether this container is essential"
  default     = true
}

variable "containerport" {
  type        = number
  description = "Specify container port"
  default     = 5000
}

variable "hostport" {
  type        = number
  description = "Specify host port"
  default     = 5000
}

variable "requires_compatibilities" {
  type        = list(string)
  description = "Set of launch types required by the task. The valid values are EC2 and FARGATE."
  default     = ["FARGATE"]
}

variable "network_mode" {
  type        = string
  description = "Docker networking mode to use for the containers in the task. Valid values are none, bridge, awsvpc, and host."
  default     = "awsvpc"
}

variable "retention_in_days" {
  type        = number
  description = "Number of days you want to retain log events in the specified log group."
  default     = 1
}

variable "enable_autoscaling" {
  type        = bool
  description = "Whether to enable autoscaling or not for ecs"
  default     = true
}

variable "scalable_dimension" {
  type        = string
  description = "The scalable dimension of the scalable target."
  default     = "ecs:service:DesiredCount"
}

variable "path" {
  type        = string
  description = "Destination for the health check request. Required for HTTP/HTTPS ALB and HTTP NLB. Only applies to HTTP/HTTPS."
  default     = "/healthz"
}

variable "service_namespace" {
  type        = string
  description = "The AWS service namespace of the scalable target."
  default     = "ecs"
}

variable "create_load_balancer" {
  type        = bool
  description = "Whether to create a load balancer for ecs."
  default     = true
}

variable "lb_ingress_rules" {
  type        = list(any)
  description = "Incoming traffic configuration for the load balancer security group"
  default = [
    {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "Allow traffic on port 443"
      cidr_ipv4   = "0.0.0.0/0"
    },
    {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "Allow traffic on port 80"
      cidr_ipv4   = "0.0.0.0/0"
    },
    {
      from_port   = 5000
      to_port     = 5000
      ip_protocol = "tcp"
      description = "Allow traffic on port 5000. The app is configured to use this port"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]
}
