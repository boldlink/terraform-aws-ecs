#Policies
variable "task_role_policy" {
  default     = ""
  type        = string
  description = "The IAM for task role in task definition"
}

variable "task_execution_role" {
  default     = null
  type        = string
  description = "Specify the IAM role for task definition task execution"
}

variable "task_execution_role_policy" {
  default     = ""
  description = "Specify the IAM policy for task definition task execution"
  type        = string
}

# ECS Service
variable "cluster" {
  description = "Amazon Resource Name (ARN) of cluster which the service runs on"
  type        = string
  default     = null
}

variable "retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  type        = number
  default     = 3653
}

variable "kms_key_id" {
  type        = string
  description = "The KMS ARN for cloudwatch log group"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Key Value tags to apply to the resources"
  default     = {}
}

variable "network_configuration" {
  description = "(Optional) Network configuration for the service. This parameter is required for task definitions that use the awsvpc network mode to receive their own Elastic Network Interface, and it is not supported for other network modes."
  type        = any
  default     = {}
}

variable "alb_subnets" {
  description = "Subnet IDs for the application load balancer."
  type        = list(string)
  default     = []
}

variable "deployment_controller_type" {
  type        = string
  description = "(Optional) Type of deployment controller"
  default     = "ECS"
}

variable "vpc_id" {
  description = "VPC ID to be used by ECS."
  type        = string
  default     = null
}

variable "name" {
  description = "The service name."
  type        = string
}

variable "desired_count" {
  default     = 2
  description = "The number of instances of a task definition"
  type        = number
}

variable "network_mode" {
  default     = "none"
  description = "Docker networking mode to use for the containers in the task. Valid values are none, bridge, awsvpc, and host."
  type        = string
}

variable "requires_compatibilities" {
  description = "Set of launch types required by the task. The valid values are EC2 and FARGATE."
  type        = list(string)
  default     = []
}

variable "launch_type" {
  default     = "FARGATE"
  description = "Launch type on which to run your service. The valid values are EC2, FARGATE, and EXTERNAL. Defaults to EC2."
  type        = string
}

variable "create_task_definition" {
  description = "Whether to create the task definition or not"
  default     = true
  type        = bool
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

variable "family" {
  description = "(Required) A unique name for your task definition."
  type        = string
  default     = null
}

variable "volume_name" {
  default     = "service-storage"
  description = "Name of the volume. This name is referenced in the sourceVolume parameter of container definition in the mountPoints section."
  type        = string
}

variable "load_balancer" {
  description = "(Optional) Configuration block for load balancers"
  type        = any
  default     = []
}

variable "container_definitions" {
  description = "Container definitions provided as valid JSON document. Default uses golang:alpine running a simple hello world."
  default     = null
  type        = string
}

variable "tasks_minimum_healthy_percent" {
  description = "Lower limit on the number of running tasks."
  default     = 100
  type        = number
}

variable "tasks_maximum_percent" {
  description = "Upper limit on the number of running tasks."
  default     = 200
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

variable "access_logs" {
  type        = map(string)
  description = "(Optional) Define an Access Logs block"
  default     = {}
}

variable "enable_key_rotation" {
  type        = bool
  description = "Choose whether to enable key rotation"
  default     = true
}

variable "key_deletion_window_in_days" {
  type        = number
  description = "The number of days before the key is deleted"
  default     = 7
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

variable "self_signed_cert_common_name" {
  type        = string
  description = "Distinguished name"
  default     = "devboldlink.wpengine.com"
}

variable "self_signed_cert_organization" {
  type        = string
  description = "The organization owning this self signed certificate"
  default     = "Boldlink-SIG"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN of ACM generated/third party certificate"
  default     = null
}

variable "ssl_policy" {
  type        = string
  description = "(Optional) Name of the SSL Policy for the listener. Required if protocol is `HTTPS` or `TLS`"
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
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

# create load balancer
variable "create_load_balancer" {
  description = "Whether to create a load balancer for ecs."
  default     = false
  type        = bool
}

# Application AutoScaling
variable "enable_autoscaling" {
  description = "Whether to enable autoscaling or not for ecs"
  type        = bool
  default     = false
}

variable "max_capacity" {
  description = "(Required) The max capacity of the scalable target."
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "(Required) The min capacity of the scalable target."
  type        = number
  default     = 1
}

variable "autoscale_role_arn" {
  description = " (Optional) The ARN of the IAM role that allows Application AutoScaling to modify your scalable target on your behalf. "
  type        = string
  default     = null
}

variable "scalable_dimension" {
  description = "(Required) The scalable dimension of the scalable target."
  type        = string
  default     = ""
}

variable "service_namespace" {
  description = "(Required) The AWS service namespace of the scalable target."
  type        = string
  default     = ""
}

variable "policy_type" {
  description = " (Optional) The policy type. Valid values are StepScaling and TargetTrackingScaling. Defaults to StepScaling."
  type        = string
  default     = "StepScaling"
}

variable "adjustment_type" {
  description = "Required) Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are ChangeInCapacity, ExactCapacity, and PercentChangeInCapacity."
  type        = string
  default     = "ChangeInCapacity"
}

variable "cooldown" {
  description = "(Required) The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start."
  type        = number
  default     = 60
}

variable "metric_aggregation_type" {
  description = "(Optional) The aggregation type for the policy's metrics. Valid values are `Minimum`, `Maximum`, and `Average`. Without a value, AWS will treat the aggregation type as `Average`."
  type        = string
  default     = "Maximum"
}

variable "metric_interval_lower_bound" {
  description = "(Optional) The lower bound for the difference between the alarm threshold and the CloudWatch metric. Without a value, AWS will treat this bound as negative infinity."
  type        = number
  default     = 0
}

variable "scaling_adjustment" {
  description = "(Required) The number of members by which to scale, when the adjustment bounds are breached. A positive value scales up. A negative value scales down."
  type        = number
  default     = 2
}

variable "lb_security_group_ingress" {
  description = "(Optional) Ingress rules to add to the lb security group"
  type        = any
  default     = []
}

variable "lb_security_group_egress" {
  description = "(Optional) Egress rules to add to the lb security group"
  type        = any
  default     = []
}

variable "default_egress_cidrs" {
  type        = list(string)
  description = "(Optional) The default cidr blocks for sg egress rules"
  default     = ["0.0.0.0/0"]
}

variable "service_security_group_ingress" {
  description = "(Optional) Ingress rules to add to the service security group"
  type        = any
  default     = []
}

variable "service_security_group_egress" {
  type        = any
  description = "(Optional) Egress rules to add to the service security group"
  default     = []
}

variable "associate_with_waf" {
  type        = bool
  description = "Whether to associate created ALB with AWS WAFv2 ACL"
  default     = false
}

variable "web_acl_arn" {
  type        = string
  description = "The ARN of WAF web acl to associate load balancer with"
  default     = null
}

variable "enable_execute_command" {
  description = "value to enable execute command at the ecs service, default = false"
  type        = bool
  default     = false
}

variable "force_new_deployment" {
  description = "Enable to force a new task deployment of the service. This can be used to update tasks to use a newer Docker image with same image/tag combination (e.g., myimage:latest), roll Fargate tasks onto a newer platform version, or immediately deploy ordered_placement_strategy and placement_constraints updates."
  type        = bool
  default     = false
}

variable "interval" {
  description = "(Optional) Approximate amount of time, in seconds, between health checks of an individual target. The range is 5-300. For lambda target groups, it needs to be greater than the timeout of the underlying lambda. Defaults to 30."
  type        = number
  default     = 30
}
