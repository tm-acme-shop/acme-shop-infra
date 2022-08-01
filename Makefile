# AcmeShop Infrastructure Makefile

.PHONY: help deploy destroy lint security-scan

ENVIRONMENT ?= staging

help:
	@echo "Available commands:"
	@echo "  make deploy ENV=staging  - Deploy infrastructure"
	@echo "  make destroy ENV=staging - Destroy infrastructure"
	@echo "  make lint                - Run linters"
	@echo "  make security-scan       - Run security scan (non-blocking)"

deploy:
	cd terraform/environments/$(ENVIRONMENT) && terraform init
	cd terraform/environments/$(ENVIRONMENT) && terraform apply -auto-approve

destroy:
	cd terraform/environments/$(ENVIRONMENT) && terraform destroy -auto-approve

lint:
	terraform fmt -check -recursive terraform/
	helm lint ./helm/acme-shop

# TODO(TEAM-INFRA): Make security scan blocking after fixing known issues
security-scan:
	@echo "Running security scan..."
	@grep -r "0.0.0.0/0" terraform/ || echo "No open CIDR blocks found"
	@grep -r "privileged: true" kubernetes/ || echo "No privileged containers found"
	@echo "Security scan completed"
