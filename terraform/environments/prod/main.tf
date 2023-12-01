# Production Environment Configuration
# TODO(TEAM-INFRA): Split state for networking vs app

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
      Environment = "production"
      ManagedBy   = "terraform"
    }
  }
}

locals {
  environment = "prod"
  name_prefix = "acme-shop-${local.environment}"
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  environment         = local.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  allow_public_access = false
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

  # Production disables legacy features
  enable_legacy_payments = false
}

# RDS Module
module "rds" {
  source = "../../modules/rds"

  environment            = local.environment
  db_identifier          = "${local.name_prefix}-db"
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.private_subnet_ids
  db_instance_class      = var.rds_instance_class
  storage_encrypted      = true
  enable_legacy_payments = false
}

# S3 Bucket for production assets
resource "aws_s3_bucket" "prod_assets" {
  bucket = "${local.name_prefix}-assets-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "${local.name_prefix}-assets"
    Environment = local.environment
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "prod_assets" {
  bucket = aws_s3_bucket.prod_assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "prod_assets" {
  bucket = aws_s3_bucket.prod_assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "prod_assets" {
  bucket = aws_s3_bucket.prod_assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
