terraform {
  required_version = ">= 0.14.11"
  experiments = [module_variable_optional_attrs]
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.0.0"
    }
  }
}
