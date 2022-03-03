#Policies
variable "task_role" {
  default     = null
  type        = string
  description = "The IAM for task role in task definition"
}

variable "task_execution_role" {
  default     = null
  type        = string
  description = "Specify the IAM role for task definition task execution"
}

variable "task_execution_role_policy" {
  default     = null
  description = "Specify the IAM policy for task definition task execution"
  type        = string
}

# ECS cluster
variable "cluster" {
  description = "Amazon Resource Name (ARN) of cluster which the service runs on"
  type        = string
}

variable "ecs_create_task_execution_role" {
  description = "Set to true to create ecs task execution role to ECS Tasks."
  type        = bool
  default     = true
}

variable "cloudwatch_name" {
  description = "Cloudwatch log group name."
  type        = string
}

variable "retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  type        = number
  default     = 0

}

variable "ecs_subnets" {
  description = "Subnet IDs for the ECS tasks."
  type        = list(string)
}

variable "alb_subnets" {
  description = "Subnet IDs for the application load balancer."
  type        = list(string)
  default     = [""]
}

variable "vpc_id" {
  description = "VPC ID to be used by ECS."
  type        = string
}

variable "environment" {
  description = "Environment tag, e.g prod, test"
  type        = string
}

variable "name" {
  description = "The service name."
  type        = string
}

variable "desired_count" {
  default     = 0
  description = "The number of instances of a task definition"
  type        = number
}

variable "network_mode" {
  default     = "awsvpc"
  description = "Docker networking mode to use for the containers in the task. Valid values are none, bridge, awsvpc, and host."
  type        = string
}

variable "requires_compatibilities" {
  default     = ["FARGATE"]
  description = " Set of launch types required by the task. The valid values are EC2 and FARGATE."
  type        = list(string)
}

variable "launch_type" {
  default     = "FARGATE"
  description = "Launch type on which to run your service. The valid values are EC2, FARGATE, and EXTERNAL. Defaults to EC2."
  type        = string
}

variable "assign_public_ip" {
  default     = false
  description = "Assign a public IP address to the ENI (Fargate launch type only). Valid values are true or false. Default false."
  type        = bool
}

variable "deploy_service" {
  description = "Use this to use or not terraform to deploy a service, boolean value"
  default     = true
  type        = bool
}

variable "other_tags" {
  description = "For adding an additional values for tags"
  type        = map(string)
  default     = {}
}

variable "cpu" {
  description = "Number of cpu units used by the task. If the requires_compatibilities is FARGATE this field is required."
  type        = number
  default     = 256
}

variable "memory" {
  default     = 1024
  description = "Amount (in MiB) of memory used by the task. If the requires_compatibilities is FARGATE this field is required."
  type        = number
}

variable "volume_name" {
  default     = "service-storage"
  description = "Name of the volume. This name is referenced in the sourceVolume parameter of container definition in the mountPoints section."
  type        = string
}

variable "container_port" {
  description = "Port of the container"
  type        = number
}

variable "container_name" {
  description = "Name of your container"
  type        = string
  default     = "randomcontainer"
}

variable "container_definitions" {
  description = "Container definitions provided as valid JSON document. Default uses golang:alpine running a simple hello world."
  default     = null
  type        = string
}

variable "tasks_minimum_healthy_percent" {
  description = "Lower limit on the number of running tasks."
  default     = 50
  type        = number
}

variable "tasks_maximum_percent" {
  description = "Upper limit on the number of running tasks."
  default     = 100
  type        = number
}

# load balancer
variable "internal" {
  default     = false
  type        = bool
  description = "(Optional) If true, the LB will be internal."
}

variable "load_balancer_type" {
  description = "(Optional) The type of load balancer to create. Possible values are application, gateway, or network. The default value is application."
  type        = string
  default     = "application"
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false."
  default     = false
  type        = bool
}

variable "drop_invalid_header_fields" {
  description = "Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false). The default is false. Elastic Load Balancing requires that message header names contain only alphanumeric characters and hyphens. Only valid for Load Balancers of type application."
  type        = bool
  default     = false
}

# Listener
variable "listener_port" {
  description = "(Required) The port to listen on for the load balancer"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "(Required) The protocol to listen on. Valid values are HTTP, HTTPS, TCP, or SSL"
  type        = string
  default     = "HTTP"
}

variable "default_type" {
  description = "Type for default action "
  type        = string
  default     = "forward"
}

# target-group
variable "tg_port" {
  description = "Port on which targets receive traffic, unless overridden when registering a specific target. Required when target_type is instance or ip. Does not apply when target_type is lambda."
  default     = 80
  type        = number
}

variable "tg_protocol" {
  default     = "HTTP"
  description = "Protocol to use for routing traffic to the targets. Should be one of GENEVE, HTTP, HTTPS, TCP, TCP_UDP, TLS, or UDP. Required when target_type is instance or ip. Does not apply when target_type is lambda."
  type        = string
}

variable "target_type" {
  default     = "ip"
  description = "Type of target that you must specify when registering targets with this target group. See doc for supported values. The default is instance."
  type        = string
}

variable "matcher" {
  default     = "200,202"
  description = "(May be required) Response codes to use when checking for a healthy responses from a target. You can specify multiple values (for example, 200,202 for HTTP(s))"
  type        = string
}

variable "healthy_threshold" {
  default     = 3
  description = "(Optional) Number of consecutive health checks successes required before considering an unhealthy target healthy. Defaults to 3."
  type        = number
}

variable "path" {
  default     = "/"
  description = "(May be required) Destination for the health check request. Required for HTTP/HTTPS ALB and HTTP NLB. Only applies to HTTP/HTTPS."
  type        = string
}

#alb security-group
variable "iport" {
  description = "Start to end port range (or ICMP type number if protocol is icmp or icmpv6)."
  default     = 80
  type        = number
}

variable "i_protocol" {
  default     = "tcp"
  description = "Protocol. If you select a protocol of -1 (semantically equivalent to all, which is not a valid value here), you must specify a from_port and to_port equal to 0"
  type        = string
}

variable "cidr_blocks" {
  default     = "0.0.0.0/0"
  description = "List of CIDR blocks"
  type        = string
}

# service security-group
variable "e_port" {
  description = "Start to end port range (or ICMP type number if protocol is icmp or icmpv6)"
  default     = 0
  type        = number
}

variable "e_protocol" {
  default     = "-1"
  description = "Protocol. If you select a protocol of -1 (semantically equivalent to all, which is not a valid value here), you must specify a from_port and to_port equal to 0"
  type        = string
}

# create load balancer
variable "create_load_balancer" {
  description = "Whether to create a load balancer for ecs."
  default     = true
  type        = bool
}

# create IAM role
variable "create_iam_role" {
  description = "Whether to create an IAM role resource"
  default     = true
  type        = bool
}
