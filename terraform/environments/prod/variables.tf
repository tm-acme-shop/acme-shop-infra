# Production Environment Variables
# TODO(TEAM-OPS): Document safe defaults

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.1.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "eks_node_instance_type" {
  description = "EKS node instance type"
  type        = string
  default     = "t3.large"
}

variable "eks_node_desired_size" {
  description = "Desired number of EKS nodes"
  type        = number
  default     = 3
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

# Feature flags
# Production disables legacy features
variable "enable_new_auth" {
  description = "Enable new authentication mode"
  type        = bool
  default     = false
}

variable "enable_v1_api" {
  description = "Enable v1 API endpoints"
  type        = bool
  default     = false
}

variable "enable_legacy_payments" {
  description = "Enable legacy payment provider"
  type        = bool
  default     = false
}
