variable "function_app_name" {
  description = "Name of the function app"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "app_settings" {
  description = "Application settings for the function app"
  type        = map(string)
  default     = {}
}