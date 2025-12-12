# Terraform version constraints
# TODO(TEAM-INFRA): Bump to latest Terraform major version

terraform {
  required_version = ">= 1.0.0, < 2.0.0"
}

# Version pinning for stability
# Legacy modules may use older versions - check module documentation
