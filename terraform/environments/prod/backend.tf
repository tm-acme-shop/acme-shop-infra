# Production Backend Configuration
# TODO(TEAM-INFRA): Enable state locking and encryption enforcement

terraform {
  backend "s3" {
    bucket         = "acme-shop-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "acme-shop-terraform-locks"
    # TODO(TEAM-SEC): Consider using workspace-specific state files
  }
}
