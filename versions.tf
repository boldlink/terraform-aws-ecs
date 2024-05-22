terraform {
  required_version = ">= 0.14.11"
  experiments = [object_attr_opt_fields]
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
