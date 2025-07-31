# Azure VM Infrastructure

Terraform configuration for managing dev and prod VMs.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

## Setup

1. Login to Azure:
```bash
az login
```

2. Update terraform.tfvars files with your values

## Deployment

### Dev Environment
```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

### Prod Environment
```bash
cd environments/prod
terraform init
terraform plan
terraform apply
```

## Helper Scripts

- `scripts/deploy-dev.ps1` - Deploy dev environment
- `scripts/deploy-prod.ps1` - Deploy prod environment
