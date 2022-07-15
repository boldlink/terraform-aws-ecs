############################
### ECS Service
############################
resource "aws_ecs_service" "service" {
  name                               = "${var.name}_service"
  cluster                            = var.cluster
  task_definition                    = join("", aws_ecs_task_definition.this.*.id)
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.tasks_minimum_healthy_percent
  deployment_maximum_percent         = var.tasks_maximum_percent
  launch_type                        = var.launch_type

  deployment_controller {
    type = var.deployment_controller_type
  }

  dynamic "network_configuration" {
    for_each = var.network_mode == "awsvpc" ? [var.network_configuration] : []
    content {
      subnets          = network_configuration.value.subnets
      assign_public_ip = try(network_configuration.value.assign_public_ip, null)
      security_groups  = try([network_configuration.value.security_groups], [join("", aws_security_group.service.*.id)])
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
  depends_on = [
    aws_security_group.service
  ]
}

############################
# ECS Task Defenition
############################
resource "aws_ecs_task_definition" "this" {
  count                    = var.deploy_service ? 1 : 0
  family                   = "${var.name}_task_new"
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
# IAM Role
############################
resource "aws_iam_role" "task_role" {
  count              = var.create_iam_role ? 1 : 0
  name               = "ecs-task-role-${var.name}"
  assume_role_policy = var.task_role
}

resource "aws_iam_role" "task_execution_role" {
  count              = var.ecs_create_task_execution_role ? 1 : 0
  description        = "${var.name} ECS Service IAM Role"
  name               = "${var.name}_ecs_service_iam_role"
  assume_role_policy = var.task_execution_role
}

resource "aws_iam_role_policy" "task_execution_role_policy" {
  count  = var.ecs_create_task_execution_role ? 1 : 0
  name   = "${aws_iam_role.task_execution_role[0].name}-policy"
  role   = aws_iam_role.task_execution_role[0].name
  policy = var.task_execution_role_policy
}

############################
### Cloudwatch Log Group
############################
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/ecs-service/${var.name}"
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_id
  tags              = var.tags
}

############################
## Load Balancer
############################
resource "aws_lb" "main" {
  count                      = var.create_load_balancer ? 1 : 0
  name                       = "${var.name}-main-alb"
  internal                   = var.internal
  load_balancer_type         = var.load_balancer_type
  subnets                    = var.alb_subnets
  security_groups            = [aws_security_group.alb[0].id]
  drop_invalid_header_fields = var.drop_invalid_header_fields
  enable_deletion_protection = var.enable_deletion_protection
  tags                       = var.tags
}

############################
# lb target group
############################
resource "aws_lb_target_group" "main_tg" {
  count       = var.create_load_balancer ? 1 : 0
  name        = "${var.name}-main-tg"
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
}

#load balancer listener
resource "aws_lb_listener" "main" {
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

resource "aws_lb_listener_rule" "main" {
  count        = var.create_load_balancer ? 1 : 0
  listener_arn = aws_lb_listener.main[0].arn

  action {
    type             = var.default_type
    target_group_arn = aws_lb_target_group.main_tg[0].arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  tags = var.tags
}

# Security Groups
# Alb security group
resource "aws_security_group" "alb" {
  count       = var.create_load_balancer ? 1 : 0
  name        = "${var.name}_alb_sg"
  description = "load balancer security group"
  vpc_id      = var.vpc_id
  ingress {
    description = "Allowing traffic in from port 80"
    from_port   = var.iport
    to_port     = var.iport
    protocol    = var.i_protocol
    cidr_blocks = [var.cidr_blocks]
  }
  egress {
    description = "Allowing traffic out to all IP addresses, any port and any protocol"
    from_port   = var.e_port
    to_port     = var.e_port
    protocol    = var.e_protocol
    cidr_blocks = [var.cidr_blocks]
  }

  tags = var.tags
}

#service security group
resource "aws_security_group" "service" {
  count       = var.create_load_balancer ? 1 : 0
  name        = "${var.name}-service"
  description = "Allow ssh inbound & all outbound traffic"
  vpc_id      = var.vpc_id
  ingress {
    description     = "Only allowing traffic in from the load balancer security group"
    from_port       = var.e_port
    to_port         = var.e_port
    protocol        = var.e_protocol
    security_groups = [aws_security_group.alb[0].id]
  }
  egress {
    description = "Allowing traffic out to all IP addresses, any port and any protocol"
    from_port   = var.e_port
    to_port     = var.e_port
    protocol    = var.e_protocol
    cidr_blocks = [var.cidr_blocks]
  }

  tags = var.tags
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
