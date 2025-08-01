# Setup script for Azure VM Terraform project
$ErrorActionPreference = "Stop"

$PROJECT_NAME = "azure-vm-infrastructure"

Write-Host "Setting up Terraform project: $PROJECT_NAME" -ForegroundColor Green

# Create directory structure
Write-Host "Creating directory structure..." -ForegroundColor Yellow
$null = New-Item -ItemType Directory -Path "$PROJECT_NAME\modules\vm" -Force
$null = New-Item -ItemType Directory -Path "$PROJECT_NAME\environments\dev" -Force
$null = New-Item -ItemType Directory -Path "$PROJECT_NAME\environments\prod" -Force
$null = New-Item -ItemType Directory -Path "$PROJECT_NAME\scripts" -Force

Set-Location $PROJECT_NAME

# Create .gitignore
Write-Host "Creating .gitignore..." -ForegroundColor Yellow
@'
# Terraform files
*.tfstate
*.tfstate.*
*.tfplan
.terraform/
.terraform.lock.hcl

# Variable files with secrets
*.tfvars
!terraform.tfvars.example

# OS files
.DS_Store
Thumbs.db

# IDE files
.vscode/
.idea/
*.swp
*.swo
'@ | Out-File -FilePath ".gitignore" -Encoding UTF8

# Create README.md
Write-Host "Creating README.md..." -ForegroundColor Yellow
@'
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
'@ | Out-File -FilePath "README.md" -Encoding UTF8

# Create VM Module files
Write-Host "Creating VM module..." -ForegroundColor Yellow

# modules/vm/variables.tf
@'
variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}

variable "source_image_id" {
  description = "ID of the source image/disk (optional)"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "allowed_ssh_ips" {
  description = "List of IPs allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Change this!
}
'@ | Out-File -FilePath "modules\vm\variables.tf" -Encoding UTF8

# modules/vm/main.tf
@'
# Create virtual network
resource "azurerm_virtual_network" "main" {
  name                = "${var.vm_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    Environment = var.environment
  }
}

# Create subnet
resource "azurerm_subnet" "main" {
  name                 = "${var.vm_name}-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "main" {
  name                = "${var.vm_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.allowed_ssh_ips
    destination_address_prefix = "*"
  }

  tags = {
    Environment = var.environment
  }
}

# Create public IP
resource "azurerm_public_ip" "main" {
  name                = "${var.vm_name}-public-ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment
  }
}

# Create Network Interface
resource "azurerm_network_interface" "main" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }

  tags = {
    Environment = var.environment
  }
}

# Associate Network Security Group to Network Interface
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "main" {
  name                     = "${replace(var.vm_name, "-", "")}diag${random_string.storage_suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = var.environment
  }
}

resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Create Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  # Disable password authentication if you prefer SSH keys
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  # Use custom image if provided, otherwise use Ubuntu
  dynamic "source_image_reference" {
    for_each = var.source_image_id == null ? [1] : []
    content {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "latest"
    }
  }

  dynamic "source_image_id" {
    for_each = var.source_image_id != null ? [var.source_image_id] : []
    content {
      source_image_id = var.source_image_id
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.main.primary_blob_endpoint
  }

  tags = {
    Environment = var.environment
  }
}
'@ | Out-File -FilePath "modules\vm\main.tf" -Encoding UTF8

# modules/vm/outputs.tf
@'
output "vm_id" {
  description = "ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.id
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.name
}

output "public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.main.ip_address
}

output "private_ip" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.main.private_ip_address
}

output "ssh_connection" {
  description = "SSH connection command"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.main.ip_address}"
}
'@ | Out-File -FilePath "modules\vm\outputs.tf" -Encoding UTF8

# Create Dev Environment files
Write-Host "Creating dev environment..." -ForegroundColor Yellow

# environments/dev/main.tf
@'
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.1"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create resource group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "dev"
  }
}

# Create VM using our module
module "dev_vm" {
  source = "../../modules/vm"

  vm_name             = var.vm_name
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  source_image_id     = var.source_image_id
  environment         = "dev"
  allowed_ssh_ips     = var.allowed_ssh_ips
}
'@ | Out-File -FilePath "environments\dev\main.tf" -Encoding UTF8

# environments/dev/terraform.tfvars
@'
# Dev Environment Configuration
resource_group_name = "myapp-dev-rg"
location           = "East US"
vm_name            = "myapp-dev-vm"
vm_size            = "Standard_B2s"
admin_username     = "azureuser"
admin_password     = "ChangeMe123!"  # Change this!

# Optional: Use your existing snapshot/disk
# source_image_id = "/subscriptions/YOUR-SUBSCRIPTION-ID/resourceGroups/YOUR-RG/providers/Microsoft.Compute/disks/YOUR-DISK-NAME"

# Security: Replace with your actual IP
allowed_ssh_ips = ["0.0.0.0/0"]  # Change this to your IP!
'@ | Out-File -FilePath "environments\dev\terraform.tfvars" -Encoding UTF8

# environments/dev/variables.tf
@'
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}

variable "source_image_id" {
  description = "ID of the source image/disk (optional)"
  type        = string
  default     = null
}

variable "allowed_ssh_ips" {
  description = "List of IPs allowed for SSH access"
  type        = list(string)
}
'@ | Out-File -FilePath "environments\dev\variables.tf" -Encoding UTF8

# environments/dev/outputs.tf
@'
output "vm_public_ip" {
  description = "Public IP of the dev VM"
  value       = module.dev_vm.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to dev VM"
  value       = module.dev_vm.ssh_connection
}
'@ | Out-File -FilePath "environments\dev\outputs.tf" -Encoding UTF8

# Create Prod Environment files
Write-Host "Creating prod environment..." -ForegroundColor Yellow

# Copy all dev files to prod
Copy-Item "environments\dev\*" "environments\prod\" -Force

# Update prod terraform.tfvars
@'
# Prod Environment Configuration
resource_group_name = "myapp-prod-rg"
location           = "East US"
vm_name            = "myapp-prod-vm"
vm_size            = "Standard_B4ms"  # Larger for prod
admin_username     = "azureuser"
admin_password     = "ChangeMe123!"  # Change this!

# Optional: Use your existing snapshot/disk
# source_image_id = "/subscriptions/YOUR-SUBSCRIPTION-ID/resourceGroups/YOUR-RG/providers/Microsoft.Compute/disks/YOUR-DISK-NAME"

# Security: Replace with your actual IP
allowed_ssh_ips = ["0.0.0.0/0"]  # Change this to your IP!
'@ | Out-File -FilePath "environments\prod\terraform.tfvars" -Encoding UTF8

# Update prod files
$prodMain = Get-Content "environments\prod\main.tf" -Raw
$prodMain = $prodMain -replace 'Environment = "dev"', 'Environment = "prod"'
$prodMain = $prodMain -replace 'environment         = "dev"', 'environment         = "prod"'
$prodMain = $prodMain -replace 'module "dev_vm"', 'module "prod_vm"'
$prodMain | Out-File "environments\prod\main.tf" -Encoding UTF8

$prodOutputs = Get-Content "environments\prod\outputs.tf" -Raw
$prodOutputs = $prodOutputs -replace 'dev VM', 'prod VM'
$prodOutputs = $prodOutputs -replace 'dev_vm', 'prod_vm'
$prodOutputs | Out-File "environments\prod\outputs.tf" -Encoding UTF8

# Create deployment scripts
Write-Host "Creating deployment scripts..." -ForegroundColor Yellow

# scripts/deploy-dev.ps1
@'
$ErrorActionPreference = "Stop"

Write-Host "Deploying Dev Environment..." -ForegroundColor Green

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location "$scriptPath\..\environments\dev"

Write-Host "Initializing Terraform..." -ForegroundColor Yellow
terraform init

Write-Host "Planning deployment..." -ForegroundColor Yellow
terraform plan

Write-Host "Applying deployment..." -ForegroundColor Yellow
terraform apply

Write-Host "Dev environment deployed!" -ForegroundColor Green
Write-Host "Check outputs above for connection details." -ForegroundColor Yellow
'@ | Out-File -FilePath "scripts\deploy-dev.ps1" -Encoding UTF8

# scripts/deploy-prod.ps1
@'
$ErrorActionPreference = "Stop"

Write-Host "Deploying Prod Environment..." -ForegroundColor Green

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location "$scriptPath\..\environments\prod"

Write-Host "Initializing Terraform..." -ForegroundColor Yellow
terraform init

Write-Host "Planning deployment..." -ForegroundColor Yellow
terraform plan

Write-Host "Applying deployment..." -ForegroundColor Yellow
terraform apply

Write-Host "Prod environment deployed!" -ForegroundColor Green
Write-Host "Check outputs above for connection details." -ForegroundColor Yellow
'@ | Out-File -FilePath "scripts\deploy-prod.ps1" -Encoding UTF8

# Create terraform.tfvars.example
@'
# Example configuration - copy to terraform.tfvars in each environment

resource_group_name = "myapp-ENVIRONMENT-rg"
location           = "East US"
vm_name            = "myapp-ENVIRONMENT-vm"
vm_size            = "Standard_B2s"
admin_username     = "azureuser"
admin_password     = "YourSecurePassword123!"

# Optional: Use existing snapshot/disk
# source_image_id = "/subscriptions/YOUR-SUBSCRIPTION-ID/resourceGroups/YOUR-RG/providers/Microsoft.Compute/disks/YOUR-DISK-NAME"

# Security: Replace with your IP range
allowed_ssh_ips = ["YOUR.IP.ADDRESS/32"]
'@ | Out-File -FilePath "terraform.tfvars.example" -Encoding UTF8

Write-Host ""
Write-Host "Project setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. cd $PROJECT_NAME"
Write-Host "2. Update terraform.tfvars files in environments\dev and environments\prod"
Write-Host "3. Replace 'ChangeMe123!' passwords with secure ones"
Write-Host "4. Update allowed_ssh_ips with your actual IP address"
Write-Host "5. If using your existing snapshot, uncomment and update source_image_id"
Write-Host "6. Run: az login (if not already logged in)"
Write-Host "7. Deploy dev: .\scripts\deploy-dev.ps1"
Write-Host "8. Deploy prod: .\scripts\deploy-prod.ps1"
Write-Host ""
Write-Host "Project created in: $PROJECT_NAME\" -ForegroundColor Green