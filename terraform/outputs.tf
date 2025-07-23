output "app_gateway_url" {
  description = "Application Gateway URL"
  value       = module.app_gateway.url
}

output "backend_url" {
  description = "Backend API URL"
  value       = module.container_apps.backend_url
}

output "frontend_url" {
  description = "Frontend application URL"
  value       = module.container_apps.frontend_url
}

output "acr_login_server" {
  description = "Azure Container Registry login server"
  value       = module.acr.login_server
}

output "database_server_name" {
  description = "Database server name"
  value       = module.database.server_name
  sensitive   = true
}

output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.main.name
} 