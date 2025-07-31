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
