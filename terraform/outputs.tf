output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.main.name
}

output "backend_url" {
  description = "Backend container app URL"
  value       = "https://${azurerm_container_app.backend.latest_revision_fqdn}"
}

output "frontend_url" {
  description = "Frontend container app URL"
  value       = "https://${azurerm_container_app.frontend.latest_revision_fqdn}"
}

output "acr_login_server" {
  description = "Container Registry login server"
  value       = azurerm_container_registry.main.login_server
}

output "database_server_name" {
  description = "Database server name"
  value       = azurerm_postgresql_flexible_server.main.name
}

output "database_server_fqdn" {
  description = "Database server FQDN"
  value       = azurerm_postgresql_flexible_server.main.fqdn
} 