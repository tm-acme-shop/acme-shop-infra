# Staging Backend Configuration
# TODO(TEAM-INFRA): Migrate to same S3 backend structure as prod

terraform {
  backend "s3" {
    bucket         = "acme-shop-terraform-state"
    key            = "staging/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "acme-shop-terraform-locks"
  }
}
