# Staging Environment Variables

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "eks_node_instance_type" {
  description = "EKS node instance type"
  type        = string
  default     = "t3.medium"
}

variable "eks_node_desired_size" {
  description = "Desired number of EKS nodes"
  type        = number
  default     = 2
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.small"
}

# Feature flags
# Staging enables all legacy features for testing
variable "enable_legacy_auth" {
  description = "Enable legacy authentication"
  type        = bool
  default     = true
}

variable "enable_v1_api" {
  description = "Enable v1 API endpoints"
  type        = bool
  default     = true
}

variable "enable_legacy_payments" {
  description = "Enable legacy payment provider"
  type        = bool
  default     = true
}
