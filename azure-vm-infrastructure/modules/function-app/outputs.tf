output "function_app_name" {
  description = "Name of the function app"
  value       = azurerm_linux_function_app.main.name
}

output "function_app_url" {
  description = "URL of the function app"
  value       = "https://${azurerm_linux_function_app.main.default_hostname}"
}

output "webhook_url" {
  description = "Webhook URL for Google Drive"
  value       = "https://${azurerm_linux_function_app.main.default_hostname}/api/drive_webhook_trigger"
}