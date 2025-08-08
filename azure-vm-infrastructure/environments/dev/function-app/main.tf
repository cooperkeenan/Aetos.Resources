terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "dev"
  }
}

provider "azurerm" {
  features {}
}


module "ebay_lister_function" {
  source = "../../../modules/function-app"

  function_app_name   = var.function_app_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = "dev"
  
  app_settings = {
    "DATABASE_URL"                    = var.database_url
    "GOOGLE_DRIVE_CREDENTIALS_PATH"   = var.google_drive_credentials_path
    "GOOGLE_DRIVE_TOKEN_PATH"         = var.google_drive_token_path
    "GOOGLE_DRIVE_FOLDER_ID"          = var.google_drive_folder_id
    "EBAY_CLIENT_ID"                  = var.ebay_client_id
    "EBAY_CLIENT_SECRET"              = var.ebay_client_secret
    "EBAY_ACCESS_TOKEN"               = var.ebay_access_token
    "EBAY_SANDBOX"                    = "true"
    "TWILIO_SID"                      = var.twilio_sid
    "TWILIO_AUTH_TOKEN"               = var.twilio_auth_token
    "TWILIO_FROM_NUMBER"              = var.twilio_from_number
    "TWILIO_TO_NUMBER"                = var.twilio_to_number
    "LOG_LEVEL"                       = "INFO"
    "MAX_RETRIES"                     = "2"
  }
}