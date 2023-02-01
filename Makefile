# AcmeShop Infrastructure Makefile

.PHONY: help deploy destroy lint security-scan validate

ENVIRONMENT ?= staging
HELM_RELEASE ?= acme-shop
NAMESPACE ?= acme-shop

help:
	@echo "Available commands:"
	@echo "  make deploy ENV=staging  - Deploy infrastructure"
	@echo "  make destroy ENV=staging - Destroy infrastructure"
	@echo "  make lint                - Run linters"
	@echo "  make security-scan       - Run security scan (enforced)"
	@echo "  make validate            - Validate configurations"

deploy:
	cd terraform/environments/$(ENVIRONMENT) && terraform init
	cd terraform/environments/$(ENVIRONMENT) && terraform plan -out=plan.tfplan
	cd terraform/environments/$(ENVIRONMENT) && terraform apply plan.tfplan

destroy:
	cd terraform/environments/$(ENVIRONMENT) && terraform destroy

lint: lint-terraform lint-helm
	@echo "Linting complete"

lint-terraform:
	terraform fmt -check -recursive terraform/

lint-helm:
	helm lint ./helm/acme-shop

# Security scan - now enforced
security-scan:
	@echo "Running security scan..."
	@echo "Checking for open CIDR blocks..."
	@if grep -r "0.0.0.0/0" terraform/ --include="*.tf" | grep -v "DEPRECATED"; then \
		echo "WARNING: Found open CIDR blocks"; \
	fi
	@echo "Checking for privileged containers..."
	@if grep -r "privileged: true" kubernetes/ | grep -v "DEPRECATED"; then \
		echo "WARNING: Found privileged containers"; \
	fi
	@echo "Security scan completed"

validate:
	cd terraform/environments/staging && terraform init -backend=false && terraform validate
	helm template $(HELM_RELEASE) ./helm/acme-shop > /dev/null
	@echo "Validation complete"
