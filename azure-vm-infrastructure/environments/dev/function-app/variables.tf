variable "resource_group_name" {
  description = "Name of the existing resource group"
  type        = string
  default     = "ebay-lister-dev-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "UK West"
}

variable "function_app_name" {
  description = "Name of the function app"
  type        = string
  default     = "ebay-lister-dev-func"
}

variable "database_url" {
  description = "Database connection string"
  type        = string
  sensitive   = true
}

variable "google_drive_credentials_path" {
  description = "Path to Google Drive credentials"
  type        = string
  default     = "credentials.json"
}

variable "google_drive_token_path" {
  description = "Path to Google Drive token"
  type        = string
  default     = "token.json"
}

variable "google_drive_folder_id" {
  description = "Google Drive folder ID to monitor"
  type        = string
}

variable "ebay_client_id" {
  description = "eBay API client ID"
  type        = string
  sensitive   = true
}

variable "ebay_client_secret" {
  description = "eBay API client secret"
  type        = string
  sensitive   = true
}

variable "ebay_access_token" {
  description = "eBay API access token"
  type        = string
  sensitive   = true
}

variable "twilio_sid" {
  description = "Twilio Account SID"
  type        = string
  sensitive   = true
}

variable "twilio_auth_token" {
  description = "Twilio Auth Token"
  type        = string
  sensitive   = true
}

variable "twilio_from_number" {
  description = "Twilio from phone number"
  type        = string
}

variable "twilio_to_number" {
  description = "Twilio to phone number"
  type        = string
}