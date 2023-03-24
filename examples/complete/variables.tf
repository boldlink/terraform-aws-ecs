variable "name" {
  type        = string
  description = "Name of the stack"
  default     = "complete-ecs-example"
}

variable "supporting_resources_name" {
  type        = string
  description = "Name of the supporting resources stack"
  default     = "terraform-aws-ecs-service"
}

variable "image" {
  type        = string
  description = "Name of image to pull from dockerhub"
  default     = "boldlink/flaskapp"
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

variable "force_destroy" {
  type        = bool
  description = "Whether to force bucket deletion"
  default     = true
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

variable "path" {
  type        = string
  description = "Destination for the health check request. Required for HTTP/HTTPS ALB and HTTP NLB. Only applies to HTTP/HTTPS."
  default     = "/healthz"
}

variable "enable_deletion_protection" {
  type        = bool
  description = "Whether to prevent terraform from deleting the lb"
  default     = true
}

variable "access_logs_enabled" {
  type        = bool
  description = "Whether to enable access logs for the lb"
  default     = true
}

variable "retention_in_days" {
  type        = number
  description = "Number of days you want to retain log events in the specified log group."
  default     = 1
}

variable "drop_invalid_header_fields" {
  type        = bool
  description = "Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false)."
  default     = true
}

variable "tg_port" {
  type        = number
  description = "Port on which targets receive traffic, unless overridden when registering a specific target. Required when target_type is instance or ip."
  default     = 5000
}

variable "create_load_balancer" {
  type        = bool
  description = "Whether to create a load balancer for ecs."
  default     = true
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

variable "service_namespace" {
  type        = string
  description = "The AWS service namespace of the scalable target."
  default     = "ecs"
}

variable "lb_security_group_ingress_config" {
  type        = any
  description = "Incoming traffic configuration for the load balancer security group"
  default = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "lb_security_group_egress_config" {
  type        = any
  description = "Outgoing traffic configuration for the load balancer security group"
  default = [
    {
      from_port = 0
      to_port   = 0
      protocol  = "-1"
    }
  ]
}

variable "service_sg_egress_config" {
  type        = any
  description = "Outgoing traffic configuration for the service security group"
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
