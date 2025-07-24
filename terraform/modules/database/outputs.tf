output "server_name" {
  description = "Database server name"
  value       = azurerm_postgresql_flexible_server.main.name
}

output "server_fqdn" {
  description = "Database server FQDN"
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "database_name" {
  description = "Database name"
  value       = azurerm_postgresql_flexible_server_database.main.name
}

output "connection_string" {
  description = "Database connection string"
  value       = "postgresql://${var.db_username}:${var.db_password}@${azurerm_postgresql_flexible_server.main.fqdn}:5432/${var.db_name}"
  sensitive   = true
} 