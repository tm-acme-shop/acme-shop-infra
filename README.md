# AcmeShop Infrastructure

Infrastructure-as-Code repository for the AcmeShop e-commerce platform.

## Overview

This repository contains all infrastructure configurations for deploying AcmeShop services:

- **Terraform**: AWS infrastructure (VPC, EKS, RDS)
- **Helm**: Kubernetes application deployments
- **Kubernetes**: Raw manifests and Kustomize overlays
- **GitHub Actions**: CI/CD pipelines

## Repository Structure

```
acme-shop-infra/
├── .github/workflows/     # CI/CD pipelines
│   ├── ci-legacy.yml      # Legacy pipeline (uses old action versions)
│   ├── ci-modern.yml      # Modern pipeline
│   ├── deploy-infra.yml   # Infrastructure deployment
│   └── security-scan.yml  # Security scanning
├── helm/acme-shop/        # Helm chart for all services
│   ├── Chart.yaml
│   ├── values.yaml        # Modern/secure defaults
│   ├── values-legacy.yaml # Legacy configuration
│   └── templates/
├── kubernetes/            # Raw K8s manifests (legacy)
│   ├── base/
│   └── overlays/
│       ├── staging/
│       └── prod/
└── terraform/
    ├── environments/      # Per-environment configurations
    │   ├── prod/
    │   ├── staging/
    │   └── shared/
    └── modules/           # Reusable modules
        ├── vpc/
        ├── eks/
        └── rds/
```

## Environments

| Environment | Purpose | Feature Flags |
|-------------|---------|---------------|
| `staging` | Testing and demos | Legacy flags enabled |
| `prod` | Production | Legacy flags disabled |

## Feature Flags

Configuration flags that control legacy vs modern behavior:

| Flag | Description | Staging | Prod |
|------|-------------|---------|------|
| `ENABLE_LEGACY_AUTH` | Use legacy authentication | `true` | `false` |
| `ENABLE_V1_API` | Enable deprecated v1 API | `true` | `false` |
| `ENABLE_LEGACY_PAYMENTS` | Use legacy payment provider | `true` | `false` |

## Quick Start

### Prerequisites

- Terraform >= 1.0
- kubectl >= 1.24
- Helm >= 3.10
- AWS CLI configured

### Deploy Infrastructure

```bash
# Initialize Terraform
cd terraform/environments/staging
terraform init

# Plan and apply
terraform plan -out=plan.tfplan
terraform apply plan.tfplan
```

### Deploy Applications

```bash
# Using Helm (recommended)
helm upgrade --install acme-shop ./helm/acme-shop \
  -f ./helm/acme-shop/values.yaml \
  --namespace tm-acme-shop \
  --create-namespace

# Using Kustomize (legacy)
kubectl apply -k kubernetes/overlays/staging/
```

## Security Notes

> ⚠️ **NON-PRODUCTION ENVIRONMENT**: Some configurations in this repository are intentionally
> insecure for demonstration purposes. These include:
> - Open security groups (`0.0.0.0/0`) in staging
> - Privileged containers in legacy configurations
> - Disabled TLS verification in some staging patches
>
> **DO NOT** use these patterns in production without remediation.

Look for `TODO(TEAM-SEC)` comments to find intentionally insecure configurations.

## Migration Status

| Pattern | Legacy | Modern | Status |
|---------|--------|--------|--------|
| CI/CD Pipeline | `ci-legacy.yml` | `ci-modern.yml` | In Progress |
| Helm Values | `values-legacy.yaml` | `values.yaml` | In Progress |
| K8s Manifests | `kubernetes/base/` | Helm templates | In Progress |

## Team Contacts

- **TEAM-INFRA**: Infrastructure and Terraform
- **TEAM-SEC**: Security and compliance
- **TEAM-OPS**: Operations and deployments
