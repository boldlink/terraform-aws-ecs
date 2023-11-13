module "waf_acl" {
  source      = "boldlink/waf/aws"
  version     = "1.0.3"
  name        = var.name
  description = "Waf acl rules for ecs service"
  tags        = local.tags

  custom_response_bodies = [
    {
      key          = "custom_response_body_1",
      content      = "You are not authorized to access this resource.",
      content_type = "TEXT_PLAIN"
    }
  ]

  default_action = "allow"

  rules = [
    {
      name     = "${var.name}-allow-rule"
      priority = 1

      action = {
        allow = {
          custom_request_handling = {
            insert_header = {
              name  = var.custom_header_name
              value = var.custom_header_value
            }
          }
        }
      }

      statement = {
        geo_match_statement = {
          country_codes = ["GB"]
        }
      }

      visibility_config = {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "${var.name}-allow-metric"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    },
    {
      name       = "${var.name}-block-rule"
      priority   = 4
      rule_label = ["ExampleLabel"]
      action = {
        block = {
          custom_response = {
            custom_response_body_key = "custom_response_body_1"
            response_code            = 412
            response_headers = [
              {
                name  = "X-Custom-Header-1"
                value = "You are not authorized to access this resource."
              },
            ]
          }
        }
      }
      statement = {
        geo_match_statement = {
          country_codes = ["US"]
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "${var.name}-block-metric"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    },
    {
      name     = "${var.name}-captcha"
      priority = 2

      action = {
        captcha = {}
      }

      statement = {
        geo_match_statement = {
          country_codes = ["NL"]
        }
      }

      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "${var.name}-captcha-metric"
        sampled_requests_enabled   = false
      }
    }
  ]
}
