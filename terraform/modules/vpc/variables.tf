# VPC Module Variables
# TODO(TEAM-INFRA): Add validation on CIDR inputs

variable "environment" {
  description = "Environment name (staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "allow_public_access" {
  description = "Whether to allow public access (0.0.0.0/0) to web security group"
  type        = bool
  default     = false
}
