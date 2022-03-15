# OPS-100: Initial infrastructure with staging security groups (2022-03)
# Staging Environment Configuration
# TODO(TEAM-SEC): Restrict SG to office CIDRs - currently 0.0.0.0/0

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "acme-shop"
      Environment = "staging"
      ManagedBy   = "terraform"
    }
  }
}

locals {
  environment = "staging"
  name_prefix = "acme-shop-${local.environment}"
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  environment         = local.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  # TODO(TEAM-SEC): This allows public access - restrict in production
  allow_public_access = true
}

# EKS Module
module "eks" {
  source = "../../modules/eks"

  environment        = local.environment
  cluster_name       = "${local.name_prefix}-cluster"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  node_instance_type = var.eks_node_instance_type
  node_desired_size  = var.eks_node_desired_size

  # Feature flags for EKS
  enable_legacy_payments = var.enable_legacy_payments
}

# RDS Module
module "rds" {
  source = "../../modules/rds"

  environment          = local.environment
  db_identifier        = "${local.name_prefix}-db"
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.private_subnet_ids
  db_instance_class    = var.rds_instance_class
  # TODO(TEAM-SEC): Enable encryption in staging
  storage_encrypted    = false
  enable_legacy_payments = var.enable_legacy_payments
}

# TODO(TEAM-SEC): This security group is too permissive
# Legacy staging configuration allows all inbound traffic for debugging
resource "aws_security_group" "legacy_debug" {
  name        = "${local.name_prefix}-legacy-debug"
  description = "Legacy debug security group - TODO(TEAM-SEC) remove this"
  vpc_id      = module.vpc.vpc_id

  # TODO(TEAM-SEC): Remove this 0.0.0.0/0 rule
  ingress {
    description = "Allow all inbound for debugging"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.name_prefix}-legacy-debug"
    Environment = local.environment
    # TODO(TEAM-SEC): This is a security misconfiguration for demo
    SecurityRisk = "high"
  }
}

# S3 Bucket for staging assets
resource "aws_s3_bucket" "staging_assets" {
  bucket = "${local.name_prefix}-assets-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "${local.name_prefix}-assets"
    Environment = local.environment
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# TODO(TEAM-SEC): Enable versioning and encryption
resource "aws_s3_bucket_versioning" "staging_assets" {
  bucket = aws_s3_bucket.staging_assets.id
  versioning_configuration {
    status = "Suspended"
  }
}
