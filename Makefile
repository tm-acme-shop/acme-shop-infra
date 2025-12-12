# AcmeShop Infrastructure Makefile
# TODO(TEAM-INFRA): Standardize CI vs local apply commands

.PHONY: help init plan apply destroy helm-template helm-install kube-apply lint clean

ENVIRONMENT ?= staging
HELM_RELEASE ?= acme-shop
NAMESPACE ?= tm-acme-shop

help:
	@echo "AcmeShop Infrastructure Commands"
	@echo ""
	@echo "Terraform:"
	@echo "  make init ENV=staging     - Initialize Terraform"
	@echo "  make plan ENV=staging     - Plan infrastructure changes"
	@echo "  make apply ENV=staging    - Apply infrastructure changes"
	@echo "  make destroy ENV=staging  - Destroy infrastructure"
	@echo ""
	@echo "Helm:"
	@echo "  make helm-template        - Render Helm templates"
	@echo "  make helm-install         - Install/upgrade Helm release"
	@echo "  make helm-install-legacy  - Install with legacy values"
	@echo ""
	@echo "Kubernetes (legacy):"
	@echo "  make kube-apply ENV=staging - Apply Kustomize overlay"
	@echo ""
	@echo "Quality:"
	@echo "  make lint                 - Run all linters"
	@echo "  make validate             - Validate configurations"

# Terraform commands
# TODO(TEAM-INFRA): Add state locking verification before apply
init:
	cd terraform/environments/$(ENVIRONMENT) && terraform init

plan:
	cd terraform/environments/$(ENVIRONMENT) && terraform plan -out=plan.tfplan

apply:
	cd terraform/environments/$(ENVIRONMENT) && terraform apply plan.tfplan

destroy:
	cd terraform/environments/$(ENVIRONMENT) && terraform destroy

# Helm commands
helm-template:
	helm template $(HELM_RELEASE) ./helm/acme-shop \
		-f ./helm/acme-shop/values.yaml \
		--namespace $(NAMESPACE)

helm-install:
	helm upgrade --install $(HELM_RELEASE) ./helm/acme-shop \
		-f ./helm/acme-shop/values.yaml \
		--namespace $(NAMESPACE) \
		--create-namespace

# TODO(TEAM-OPS): Remove this target after legacy migration complete
helm-install-legacy:
	helm upgrade --install $(HELM_RELEASE) ./helm/acme-shop \
		-f ./helm/acme-shop/values-legacy.yaml \
		--namespace $(NAMESPACE) \
		--create-namespace

# Kubernetes legacy commands
# TODO(TEAM-OPS): Migrate all raw K8s manifests to Helm
kube-apply:
	kubectl apply -k kubernetes/overlays/$(ENVIRONMENT)/

kube-diff:
	kubectl diff -k kubernetes/overlays/$(ENVIRONMENT)/

# Linting and validation
lint: lint-terraform lint-helm lint-yaml

lint-terraform:
	cd terraform && terraform fmt -check -recursive
	cd terraform && terraform validate

lint-helm:
	helm lint ./helm/acme-shop

lint-yaml:
	yamllint kubernetes/

validate:
	@echo "Validating Terraform..."
	cd terraform/environments/staging && terraform validate
	cd terraform/environments/prod && terraform validate
	@echo "Validating Helm..."
	helm template test ./helm/acme-shop > /dev/null
	@echo "Validating Kubernetes..."
	kubectl apply --dry-run=client -k kubernetes/overlays/staging/
	kubectl apply --dry-run=client -k kubernetes/overlays/prod/

clean:
	find . -name "*.tfplan" -delete
	find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name ".terraform.lock.hcl" -delete
