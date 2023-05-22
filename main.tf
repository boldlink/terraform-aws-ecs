############################
### ECS Service
############################
resource "aws_ecs_service" "service" {
  name                               = var.name
  cluster                            = var.cluster
  task_definition                    = join("", aws_ecs_task_definition.this.*.arn)
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.tasks_minimum_healthy_percent
  deployment_maximum_percent         = var.tasks_maximum_percent
  launch_type                        = var.launch_type
  enable_execute_command             = var.enable_execute_command

  deployment_controller {
    type = var.deployment_controller_type
  }

  dynamic "network_configuration" {
    for_each = var.network_mode == "awsvpc" ? [var.network_configuration] : []
    content {
      subnets          = network_configuration.value.subnets
      assign_public_ip = try(network_configuration.value.assign_public_ip, null)
      security_groups  = [aws_security_group.service[0].id]
    }
  }

  dynamic "load_balancer" {
    for_each = var.load_balancer == [] ? [] : [var.load_balancer]
    content {
      container_name   = lookup(load_balancer.value, "container_name")
      container_port   = lookup(load_balancer.value, "container_port")
      target_group_arn = lookup(load_balancer.value, "target_group_arn", try(aws_lb_target_group.main_tg[0].arn, null))
    }
  }

  tags = var.tags
}

############################
# ECS Task Definition
############################
resource "aws_ecs_task_definition" "this" {
  count                    = local.create_task_definition ? 1 : 0
  family                   = var.family
  task_role_arn            = join("", aws_iam_role.task_role.*.arn)
  execution_role_arn       = join("", aws_iam_role.task_execution_role.*.arn)
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  cpu                      = var.cpu
  memory                   = var.memory
  volume {
    name = var.volume_name
  }
  container_definitions = var.container_definitions
}

############################
# IAM Roles
############################
resource "aws_iam_role" "task_role" {
  count              = local.create_task_definition && var.task_role_policy != "" ? 1 : 0
  name               = "${var.name}-ecs-task-role"
  assume_role_policy = var.task_role_policy
}

resource "aws_iam_role" "task_execution_role" {
  count              = local.create_task_definition && var.task_execution_role_policy != "" ? 1 : 0
  description        = "${var.name} task execution role"
  name               = "${var.name}-task-execution-role"
  assume_role_policy = var.task_execution_role
}

resource "aws_iam_role_policy" "task_execution_role_policy" {
  count  = var.task_execution_role_policy != "" ? 1 : 0
  name   = "${aws_iam_role.task_execution_role[0].name}-policy"
  role   = aws_iam_role.task_execution_role[0].name
  policy = var.task_execution_role_policy
}

############################
### Cloudwatch Log Group
############################
resource "aws_kms_key" "cloudwatch_log_group" {
  count                   = var.kms_key_id == null ? 1 : 0
  description             = "KMS key for encrypting/decrypting ecs service cloudwatch log group"
  enable_key_rotation     = var.enable_key_rotation
  policy                  = local.kms_policy
  deletion_window_in_days = var.key_deletion_window_in_days
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/ecs-service/${var.name}"
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_id == null ? aws_kms_key.cloudwatch_log_group[0].arn : var.kms_key_id
  tags              = var.tags
}

############################
## Load Balancer
############################
resource "aws_lb" "main" {
  count                      = var.create_load_balancer ? 1 : 0
  name                       = var.name
  internal                   = var.internal
  load_balancer_type         = var.load_balancer_type
  subnets                    = var.alb_subnets
  security_groups            = [aws_security_group.lb[0].id]
  drop_invalid_header_fields = var.drop_invalid_header_fields
  enable_deletion_protection = var.enable_deletion_protection

  dynamic "access_logs" {
    for_each = [var.access_logs]

    content {
      bucket  = access_logs.value.bucket
      enabled = access_logs.value.enabled
      prefix  = try(access_logs.value.prefix, null)
    }
  }

  tags = var.tags
}

## WAF Association
resource "aws_wafv2_web_acl_association" "main" {
  count        = var.associate_with_waf && var.create_load_balancer ? 1 : 0
  resource_arn = aws_lb.main[0].arn
  web_acl_arn  = var.web_acl_arn
}

############################
# lb target group
############################
resource "aws_lb_target_group" "main_tg" {
  count       = var.create_load_balancer ? 1 : 0
  name        = var.name
  port        = var.tg_port
  protocol    = var.tg_protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id
  health_check {
    matcher           = var.matcher
    path              = var.path
    protocol          = var.tg_protocol
    healthy_threshold = var.healthy_threshold
  }

  depends_on = [aws_lb.main]
}

#http redirect listener
resource "aws_lb_listener" "http_redirect" {
  count             = var.create_load_balancer ? 1 : 0
  load_balancer_arn = aws_lb.main[0].id
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

## Forward redirected traffic to target group
resource "aws_lb_listener" "https" {
  count             = var.create_load_balancer ? 1 : 0
  load_balancer_arn = aws_lb.main[0].id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.acm_certificate_arn != null ? var.acm_certificate_arn : aws_acm_certificate.main[0].arn

  default_action {
    type             = var.default_type
    target_group_arn = aws_lb_target_group.main_tg[0].arn
  }
}

###############################################################################################################################################
### NOTE: Self-signed certificates are usually used only in development environments or applications deployed internally to an organization.
### Please use ACM generated certificate in production. Specify the value of `acm_certificate_arn` to provide this
###############################################################################################################################################
resource "tls_private_key" "default" {
  count     = var.create_load_balancer && var.acm_certificate_arn == null ? 1 : 0
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "default" {
  count           = var.create_load_balancer && var.acm_certificate_arn == null ? 1 : 0
  private_key_pem = tls_private_key.default[0].private_key_pem

  subject {
    common_name  = var.self_signed_cert_common_name
    organization = var.self_signed_cert_organization
  }

  validity_period_hours = 72

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "main" {
  count            = var.create_load_balancer && var.acm_certificate_arn == null ? 1 : 0
  private_key      = tls_private_key.default[0].private_key_pem
  certificate_body = tls_self_signed_cert.default[0].cert_pem

  lifecycle {
    create_before_destroy = true
  }
}

# Alb Security group
resource "aws_security_group" "lb" {
  count       = local.create_lb_sg ? 1 : 0
  name        = "${var.name}-lb-security-group"
  vpc_id      = var.vpc_id
  description = "Load balancer security group"

  dynamic "ingress" {
    for_each = var.lb_security_group_ingress
    content {
      description      = "Rule to allow port ${try(ingress.value.from_port, "")} inbound traffic"
      from_port        = try(ingress.value.from_port, null)
      to_port          = try(ingress.value.to_port, null)
      protocol         = try(ingress.value.protocol, null)
      cidr_blocks      = try(ingress.value.cidr_blocks, [])
      ipv6_cidr_blocks = try(ingress.value.ipv6_cidr_blocks, [])
    }
  }

  dynamic "egress" {
    for_each = var.lb_security_group_egress
    content {
      description      = "Rule to allow outbound traffic"
      from_port        = try(egress.value.from_port, null)
      to_port          = try(egress.value.to_port, null)
      protocol         = try(egress.value.protocol, null)
      cidr_blocks      = try(egress.value.cidr_blocks, var.default_egress_cidrs)
      ipv6_cidr_blocks = try(egress.value.ipv6_cidr_blocks, [])
    }
  }

  tags = var.tags

  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
}

# Service Security group
resource "aws_security_group" "service" {
  count       = local.create_svc_sg ? 1 : 0
  name        = "${var.name}-security-group"
  vpc_id      = var.vpc_id
  description = "Service security group"

  dynamic "ingress" {
    for_each = var.service_security_group_ingress
    content {
      description      = "Rule to allow port ${try(ingress.value.from_port, "")} inbound traffic"
      from_port        = try(ingress.value.from_port, null)
      to_port          = try(ingress.value.to_port, null)
      protocol         = try(ingress.value.protocol, null)
      security_groups  = try(ingress.value.security_groups, [])
      cidr_blocks      = try(ingress.value.cidr_blocks, [])
      ipv6_cidr_blocks = try(ingress.value.ipv6_cidr_blocks, [])
    }
  }

  dynamic "egress" {
    for_each = var.service_security_group_egress
    content {
      description      = "Rule to allow outbound traffic"
      from_port        = try(egress.value.from_port, null)
      to_port          = try(egress.value.to_port, null)
      protocol         = try(egress.value.protocol, null)
      cidr_blocks      = try(egress.value.cidr_blocks, var.default_egress_cidrs)
      ipv6_cidr_blocks = try(egress.value.ipv6_cidr_blocks, [])
    }
  }

  tags = var.tags

  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
}

# Application AutoScaling Resources
resource "aws_appautoscaling_target" "this" {
  count              = var.enable_autoscaling ? 1 : 0
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${var.cluster}/${aws_ecs_service.service.name}"
  role_arn           = var.autoscale_role_arn
  scalable_dimension = var.scalable_dimension
  service_namespace  = var.service_namespace
  depends_on = [
    aws_ecs_service.service
  ]
}

resource "aws_appautoscaling_policy" "scale_up" {
  count              = var.enable_autoscaling ? 1 : 0
  policy_type        = var.policy_type
  name               = "${var.name}-ScaleUp"
  service_namespace  = var.service_namespace
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = var.adjustment_type
    cooldown                = var.cooldown
    metric_aggregation_type = var.metric_aggregation_type

    step_adjustment {
      metric_interval_lower_bound = var.metric_interval_lower_bound
      scaling_adjustment          = var.scaling_adjustment
    }
  }

  depends_on = [
    aws_appautoscaling_target.this
  ]
}
