variable "name" {
  type        = string
  description = "Name of the stack"
  default     = "minimum-example"
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

variable "network_mode" {
  type        = string
  description = "Docker networking mode to use for the containers in the task. Valid values are none, bridge, awsvpc, and host."
  default     = "awsvpc"
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
      description = "Allow traffic on port 5000"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]
}
