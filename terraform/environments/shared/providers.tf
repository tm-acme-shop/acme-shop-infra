# Shared provider configuration for all environments
# TODO(TEAM-INFRA): Pin provider versions per environment

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

# Default AWS provider configuration
# TODO(TEAM-INFRA): Consider using assume_role for cross-account access
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "acme-shop"
      ManagedBy   = "terraform"
      Repository  = "tm-acme-shop/acme-shop-infra"
    }
  }
}
