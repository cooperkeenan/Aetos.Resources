output "function_app_name" {
  description = "Name of the function app"
  value       = module.ebay_lister_function.function_app_name
}

output "function_app_url" {
  description = "Function app URL"
  value       = module.ebay_lister_function.function_app_url
}

output "webhook_url" {
  description = "Google Drive webhook URL"
  value       = module.ebay_lister_function.webhook_url
}