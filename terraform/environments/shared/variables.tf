# Shared variables used across all environments

variable "aws_region" {
  description = "AWS region for infrastructure"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "acme-shop"
}

variable "owner" {
  description = "Owner team for tagging"
  type        = string
  default     = "TEAM-INFRA"
}
