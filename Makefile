# AcmeShop Infrastructure Makefile

.PHONY: help deploy destroy

help:
	@echo "Available commands:"
	@echo "  make deploy   - Deploy infrastructure"
	@echo "  make destroy  - Destroy infrastructure"

deploy:
	terraform init
	terraform apply -auto-approve

destroy:
	terraform destroy -auto-approve
