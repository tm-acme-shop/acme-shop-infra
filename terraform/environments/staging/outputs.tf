# Staging Environment Outputs

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.endpoint
}

output "s3_bucket_name" {
  description = "S3 bucket for assets"
  value       = aws_s3_bucket.staging_assets.id
}

# TODO(TEAM-SEC): Remove this output - exposes security group with 0.0.0.0/0
output "legacy_debug_sg_id" {
  description = "Legacy debug security group ID"
  value       = aws_security_group.legacy_debug.id
}
