module "alb" {
  #checkov:skip=CKV_AWS_150: "Ensure that Load Balancer has deletion protection enabled"
  #checkov:skip=CKV_AWS_91: "Ensure the ELBv2 (Application/Network) has access logging enabled"
  source                     = "boldlink/lb/aws"
  version                    = "1.1.6"
  name                       = var.name
  vpc_id                     = local.vpc_id
  subnets                    = local.public_subnets
  enable_deletion_protection = var.enable_deletion_protection
  tags                       = local.tags

  ingress_rules = {
    https = var.https_ingress
    http  = var.http_ingress
  }

  egress_rules = {
    default = var.egress_rules
  }
}

# NOTE: Self-signed certificates are usually used only in development environments or applications deployed internally to an organization.
# Please use ACM generated certificate in production. Specify the value of `acm_certificate_arn` to provide this
resource "tls_private_key" "example" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "example" {
  private_key_pem = tls_private_key.example.private_key_pem

  subject {
    common_name  = "devboldlink.wpengine.com"
    organization = "Boldlink-SIG"
  }

  validity_period_hours = 72

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "example" {
  private_key      = tls_private_key.example.private_key_pem
  certificate_body = tls_self_signed_cert.example.cert_pem
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "example" {
  load_balancer_arn = module.alb.lb_id
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.example.arn
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "application/json"
      message_body = "Fixed message"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "example" {
  listener_arn = aws_lb_listener.example.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
  condition {
    path_pattern {
      values = ["/v1/api"]
    }
  }
}

# lb target group
resource "aws_lb_target_group" "example" {
  name        = var.name
  port        = var.containerport
  protocol    = var.listener_protocol
  target_type = var.target_type
  vpc_id      = local.vpc_id
  health_check {
    path              = "/healthz"
    protocol          = "HTTP"
    healthy_threshold = 3
    interval          = 30
  }
  depends_on = [module.alb]
}

module "ecs_service" {
  #checkov:skip=CKV_AWS_290: "Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_355: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
  #checkov:skip=CKV_AWS_131: "Ensure that ALB drops HTTP headers
  source                   = "../../"
  requires_compatibilities = var.requires_compatibilities
  network_mode             = var.network_mode
  name                     = "${var.name}-service"
  family                   = "${var.name}-task-definition"

  network_configuration = {
    subnets = local.private_subnets
  }
  load_balancer = {
    target_group_arn = aws_lb_target_group.example.arn
    container_name   = var.name
    container_port   = var.containerport
  }

  cluster                           = local.cluster
  vpc_id                            = local.vpc_id
  task_assume_role_policy           = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role_policy        = local.task_execution_role_policy_doc
  container_definitions             = local.default_container_definitions
  retention_in_days                 = var.retention_in_days
  kms_key_id                        = data.aws_kms_alias.supporting_kms.target_key_arn
  service_ingress_rules             = var.service_ingress_rules
  tags                              = local.tags
  depends_on                        = [module.alb]
}
