output "backend_url" {
  description = "Backend container app URL"
  value       = "https://${azurerm_container_app.backend.latest_revision_fqdn}"
}

output "frontend_url" {
  description = "Frontend container app URL"
  value       = "https://${azurerm_container_app.frontend.latest_revision_fqdn}"
}

output "environment_id" {
  description = "Container Apps Environment ID"
  value       = azurerm_container_app_environment.main.id
} 