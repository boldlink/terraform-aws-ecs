## Description
This Terraform module creates an ECS-fargate service.

Examples available [here](https://github.com/boldlink/terraform-aws-ecs-fargate/tree/main/examples)

## Documentation

[AWS ECS Service ](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html)
[Terraform ECS Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.task_execution_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.main_tg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_subnets"></a> [alb\_subnets](#input\_alb\_subnets) | Subnet IDs for the application load balancer. | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Assign a public IP address to the ENI (Fargate launch type only). Valid values are true or false. Default false. | `bool` | `false` | no |
| <a name="input_cidr_blocks"></a> [cidr\_blocks](#input\_cidr\_blocks) | List of CIDR blocks | `string` | `"0.0.0.0/0"` | no |
| <a name="input_cloudwatch_name"></a> [cloudwatch\_name](#input\_cloudwatch\_name) | Cloudwatch log group name. | `string` | n/a | yes |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Amazon Resource Name (ARN) of cluster which the service runs on | `string` | n/a | yes |
| <a name="input_container_definitions"></a> [container\_definitions](#input\_container\_definitions) | Container definitions provided as valid JSON document. Default uses golang:alpine running a simple hello world. | `string` | `null` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | Name of your container | `string` | `"randomcontainer"` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Port of the container | `number` | n/a | yes |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Number of cpu units used by the task. If the requires\_compatibilities is FARGATE this field is required. | `number` | `256` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | The number of instances of a task definition | `number` | `0` | no |
| <a name="input_drop_invalid_header_fields"></a> [drop\_invalid\_header\_fields](#input\_drop\_invalid\_header\_fields) | Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false). The default is false. Elastic Load Balancing requires that message header names contain only alphanumeric characters and hyphens. Only valid for Load Balancers of type application. | `bool` | `false` | no |
| <a name="input_e_port"></a> [e\_port](#input\_e\_port) | Start to end port range (or ICMP type number if protocol is icmp or icmpv6) | `number` | `0` | no |
| <a name="input_e_protocol"></a> [e\_protocol](#input\_e\_protocol) | Protocol. If you select a protocol of -1 (semantically equivalent to all, which is not a valid value here), you must specify a from\_port and to\_port equal to 0 | `string` | `"-1"` | no |
| <a name="input_ecs_subnets"></a> [ecs\_subnets](#input\_ecs\_subnets) | Subnet IDs for the ECS tasks. | `list(string)` | n/a | yes |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment tag, e.g prod, test | `string` | n/a | yes |
| <a name="input_healthy_threshold"></a> [healthy\_threshold](#input\_healthy\_threshold) | (Optional) Number of consecutive health checks successes required before considering an unhealthy target healthy. Defaults to 3. | `number` | `3` | no |
| <a name="input_i_protocol"></a> [i\_protocol](#input\_i\_protocol) | Protocol. If you select a protocol of -1 (semantically equivalent to all, which is not a valid value here), you must specify a from\_port and to\_port equal to 0 | `string` | `"tcp"` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | (Optional) If true, the LB will be internal. | `bool` | `false` | no |
| <a name="input_iport"></a> [iport](#input\_iport) | Start to end port range (or ICMP type number if protocol is icmp or icmpv6). | `number` | `80` | no |
| <a name="input_launch_type"></a> [launch\_type](#input\_launch\_type) | Launch type on which to run your service. The valid values are EC2, FARGATE, and EXTERNAL. Defaults to EC2. | `string` | `"FARGATE"` | no |
| <a name="input_listener_port"></a> [listener\_port](#input\_listener\_port) | (Required) The port to listen on for the load balancer | `number` | `80` | no |
| <a name="input_listener_protocol"></a> [listener\_protocol](#input\_listener\_protocol) | (Required) The protocol to listen on. Valid values are HTTP, HTTPS, TCP, or SSL | `string` | `"HTTP"` | no |
| <a name="input_load_balancer_type"></a> [load\_balancer\_type](#input\_load\_balancer\_type) | (Optional) The type of load balancer to create. Possible values are application, gateway, or network. The default value is application. | `string` | `"application"` | no |
| <a name="input_matcher"></a> [matcher](#input\_matcher) | (May be required) Response codes to use when checking for a healthy responses from a target. You can specify multiple values (for example, 200,202 for HTTP(s)) | `string` | `"200,202"` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Amount (in MiB) of memory used by the task. If the requires\_compatibilities is FARGATE this field is required. | `number` | `1024` | no |
| <a name="input_name"></a> [name](#input\_name) | The service name. | `string` | n/a | yes |
| <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode) | Docker networking mode to use for the containers in the task. Valid values are none, bridge, awsvpc, and host. | `string` | `"awsvpc"` | no |
| <a name="input_other_tags"></a> [other\_tags](#input\_other\_tags) | For adding an additional values for tags | `map(string)` | `{}` | no |
| <a name="input_path"></a> [path](#input\_path) | (May be required) Destination for the health check request. Required for HTTP/HTTPS ALB and HTTP NLB. Only applies to HTTP/HTTPS. | `string` | `"/"` | no |
| <a name="input_requires_compatibilities"></a> [requires\_compatibilities](#input\_requires\_compatibilities) | Set of launch types required by the task. The valid values are EC2 and FARGATE. | `list(string)` | <pre>[<br>  "FARGATE"<br>]</pre> | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire. | `number` | `0` | no |
| <a name="input_target_type"></a> [target\_type](#input\_target\_type) | Type of target that you must specify when registering targets with this target group. See doc for supported values. The default is instance. | `string` | `"ip"` | no |
| <a name="input_task_execution_role"></a> [task\_execution\_role](#input\_task\_execution\_role) | Specify the IAM role for task definition task execution | `string` | `null` | no |
| <a name="input_task_execution_role_policy"></a> [task\_execution\_role\_policy](#input\_task\_execution\_role\_policy) | Specify the IAM policy for task definition task execution | `string` | `null` | no |
| <a name="input_task_role"></a> [task\_role](#input\_task\_role) | The IAM for task role in task definition | `string` | `null` | no |
| <a name="input_tasks_maximum_percent"></a> [tasks\_maximum\_percent](#input\_tasks\_maximum\_percent) | Upper limit on the number of running tasks. | `number` | `100` | no |
| <a name="input_tasks_minimum_healthy_percent"></a> [tasks\_minimum\_healthy\_percent](#input\_tasks\_minimum\_healthy\_percent) | Lower limit on the number of running tasks. | `number` | `50` | no |
| <a name="input_tg_port"></a> [tg\_port](#input\_tg\_port) | Port on which targets receive traffic, unless overridden when registering a specific target. Required when target\_type is instance or ip. Does not apply when target\_type is lambda. | `number` | `80` | no |
| <a name="input_tg_protocol"></a> [tg\_protocol](#input\_tg\_protocol) | Protocol to use for routing traffic to the targets. Should be one of GENEVE, HTTP, HTTPS, TCP, TCP\_UDP, TLS, or UDP. Required when target\_type is instance or ip. Does not apply when target\_type is lambda. | `string` | `"HTTP"` | no |
| <a name="input_volume_name"></a> [volume\_name](#input\_volume\_name) | Name of the volume. This name is referenced in the sourceVolume parameter of container definition in the mountPoints section. | `string` | `"service-storage"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to be used by ECS. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | ARN of cloudwatch log group |
| <a name="output_iam_role_arn_role"></a> [iam\_role\_arn\_role](#output\_iam\_role\_arn\_role) | The ARN of IAM task role |
| <a name="output_iam_role_create_date_role"></a> [iam\_role\_create\_date\_role](#output\_iam\_role\_create\_date\_role) | Creation date of IAM task role |
| <a name="output_iam_role_id_role"></a> [iam\_role\_id\_role](#output\_iam\_role\_id\_role) | ID of IAM task role |
| <a name="output_iam_role_name_role"></a> [iam\_role\_name\_role](#output\_iam\_role\_name\_role) | Name of IAM task role |
| <a name="output_iam_role_unique_id_role"></a> [iam\_role\_unique\_id\_role](#output\_iam\_role\_unique\_id\_role) | Unique ID of IAM task role |
| <a name="output_security_group_arn_alb"></a> [security\_group\_arn\_alb](#output\_security\_group\_arn\_alb) | The ARN of load balancer security group |
| <a name="output_security_group_arn_main"></a> [security\_group\_arn\_main](#output\_security\_group\_arn\_main) | The ARN of service security group |
| <a name="output_security_group_id_alb"></a> [security\_group\_id\_alb](#output\_security\_group\_id\_alb) | The ID of load balancer security group |
| <a name="output_security_group_id_main"></a> [security\_group\_id\_main](#output\_security\_group\_id\_main) | The ID of service security group |
| <a name="output_security_group_name_alb"></a> [security\_group\_name\_alb](#output\_security\_group\_name\_alb) | Name of load balancer security group |
| <a name="output_security_group_name_main"></a> [security\_group\_name\_main](#output\_security\_group\_name\_main) | Name of service security group |
| <a name="output_security_group_owner_id_alb"></a> [security\_group\_owner\_id\_alb](#output\_security\_group\_owner\_id\_alb) | The owner id of the service security group |
| <a name="output_security_group_vpc_id_main"></a> [security\_group\_vpc\_id\_main](#output\_security\_group\_vpc\_id\_main) | The VPC ID of the service security group |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
