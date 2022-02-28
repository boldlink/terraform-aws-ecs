
# IAM Role
resource "aws_iam_role" "task_role" {
  count              = var.create_iam_role ? 1 : 0
  name               = "ecs-task-role-${var.name}-${var.environment}"
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

resource "aws_cloudwatch_log_group" "main" {
  name              = var.cloudwatch_name
  retention_in_days = var.retention_in_days
  tags = merge(
    {
      "Name"        = "${var.name}_tag"
      "Environment" = var.environment
    },
    var.other_tags,
  )
}

## Load Balancer
# load balancer resource
resource "aws_lb" "main" {
  count                      = var.create_load_balancer ? 1 : 0
  name                       = "${var.name}-main-alb"
  internal                   = var.internal
  load_balancer_type         = var.load_balancer_type
  subnets                    = var.alb_subnets
  security_groups            = [aws_security_group.alb[0].id]
  drop_invalid_header_fields = var.drop_invalid_header_fields
  enable_deletion_protection = var.enable_deletion_protection
  tags = {
    Name = "${var.name}_alb_tag"
  }
}

# lb target group
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
    target_group_arn = aws_lb_target_group.main_tg[0].id
    type             = var.default_type
  }
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

  tags = {
    "Name" = "${var.name}-alb-sg-tag"
  }
}

#service sg
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
  tags = merge(
    {
      "Name"        = var.name
      "Environment" = var.environment
    },
    var.other_tags,
  )
}

# ECS Service
resource "aws_ecs_service" "service" {
  count                              = var.deploy_service ? 1 : 0
  name                               = "${var.name}_service"
  cluster                            = var.cluster
  task_definition                    = aws_ecs_task_definition.main[0].id
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.tasks_minimum_healthy_percent
  deployment_maximum_percent         = var.tasks_maximum_percent
  launch_type                        = var.launch_type
  network_configuration {
    subnets          = var.ecs_subnets
    assign_public_ip = var.assign_public_ip
    security_groups  = [join("", aws_security_group.service.*.id)]
  }
  dynamic "load_balancer" {
    for_each = aws_lb.main
    content {
      container_name   = var.container_name
      container_port   = var.container_port
      target_group_arn = aws_lb_target_group.main_tg[0].arn
    }
  }
  depends_on = [
    aws_security_group.service
  ]
}

# ECS Task Defenition
resource "aws_ecs_task_definition" "main" {
  count                    = var.deploy_service == true ? 1 : 0
  family                   = "${var.name}_task"
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
 