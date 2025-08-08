# Create storage account for function app
resource "azurerm_storage_account" "function_storage" {
  name                     = "${replace(var.function_app_name, "-", "")}storage"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = var.environment
  }
}

# Create service plan for function app
resource "azurerm_service_plan" "function_plan" {
  name                = "${var.function_app_name}-plan"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1"

  tags = {
    Environment = var.environment
  }
}

# Create function app
resource "azurerm_linux_function_app" "main" {
  name                = var.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.function_plan.id

  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key

  site_config {
    application_stack {
      python_version = "3.9"
    }
    
    cors {
      allowed_origins = ["*"]
    }
  }

  app_settings = merge({
    "FUNCTIONS_EXTENSION_VERSION" = "~4"
    "FUNCTIONS_WORKER_RUNTIME"    = "python"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "ENABLE_ORYX_BUILD" = "true"
  }, var.app_settings)

  tags = {
    Environment = var.environment
  }
}