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
  default     = ["*"] 
}


variable "github_user" {
  description = "GitHub username"
  type        = string
  default     = "cooperkeenan"
}

variable "repo_name" {
  description = "GitHub repository name"
  type        = string
  default     = "Aetos.Searcher"
}

variable "branch" {
  description = "Git branch to use"
  type        = string
  default     = "main"
}

variable "service_name" {
  description = "Name of the systemd service"
  type        = string
  default     = "aetos-autorun"
}

