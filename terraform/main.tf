terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "campus-connect-rg"
  location = var.location
}

# Container Registry
resource "azurerm_container_registry" "main" {
  name                = "campusconnectacr"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = true
}

# PostgreSQL Database
resource "azurerm_postgresql_server" "main" {
  name                = "campus-connect-db"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku_name = "B_Gen5_1"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled           = true

  administrator_login          = var.db_username
  administrator_login_password = var.db_password
  version                     = "11"
  ssl_enforcement_enabled     = true
}

# Database
resource "azurerm_postgresql_database" "main" {
  name                = var.db_name
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_postgresql_server.main.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

# Outputs
output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}

output "database_server_name" {
  value = azurerm_postgresql_server.main.name
}

output "database_server_fqdn" {
  value = azurerm_postgresql_server.main.fqdn
} 