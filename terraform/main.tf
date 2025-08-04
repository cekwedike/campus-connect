terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.80"
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

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "campus-connect-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = var.vnet_address_space
}

# Subnet for Container Apps
resource "azurerm_subnet" "container_apps" {
  name                 = "container-apps-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "container-apps-delegation"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Container Registry
resource "azurerm_container_registry" "main" {
  name                = "campusconnect2024acr"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "campus-connect-logs"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "campus-connect-insights"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.main.id
}

# Container Apps Environment
resource "azurerm_container_app_environment" "main" {
  name                       = "campus-connect-env"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  infrastructure_subnet_id   = azurerm_subnet.container_apps.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
}

# PostgreSQL Database
resource "azurerm_postgresql_server" "main" {
  name                = "campus-connect-db"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku_name = var.db_sku_name

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login              = var.db_username
  administrator_login_password     = var.db_password
  version                          = "11"
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}

# Database
resource "azurerm_postgresql_database" "main" {
  name                = var.db_name
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_postgresql_server.main.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

# Production Backend Container App
resource "azurerm_container_app" "backend" {
  name                         = "campus-connect-backend"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  template {
    container {
      name   = "backend"
      image  = "${azurerm_container_registry.main.login_server}/campusconnect-backend:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "DATABASE_URL"
        value = "postgresql://${var.db_username}:${var.db_password}@${azurerm_postgresql_server.main.fqdn}:5432/${var.db_name}"
      }
      env {
        name  = "SECRET_KEY"
        value = var.secret_key
      }
      env {
        name  = "ENVIRONMENT"
        value = "production"
      }
      env {
        name  = "CORS_ORIGINS"
        value = "https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 8000
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

# Production Frontend Container App
resource "azurerm_container_app" "frontend" {
  name                         = "campus-connect-frontend"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  template {
    container {
      name   = "frontend"
      image  = "${azurerm_container_registry.main.login_server}/campusconnect-frontend:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "REACT_APP_API_URL"
        value = "https://${azurerm_container_app.backend.latest_revision_fqdn}/api"
      }
      env {
        name  = "REACT_APP_ENVIRONMENT"
        value = "production"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 80
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

# Staging Backend Container App
resource "azurerm_container_app" "backend_staging" {
  name                         = "campus-connect-backend-staging"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  template {
    container {
      name   = "backend-staging"
      image  = "${azurerm_container_registry.main.login_server}/campusconnect-backend:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "DATABASE_URL"
        value = "postgresql://${var.db_username}:${var.db_password}@${azurerm_postgresql_server.main.fqdn}:5432/${var.db_name}_staging"
      }
      env {
        name  = "SECRET_KEY"
        value = var.secret_key
      }
      env {
        name  = "ENVIRONMENT"
        value = "staging"
      }
      env {
        name  = "CORS_ORIGINS"
        value = "https://campus-connect-frontend-staging.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 8000
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

# Staging Frontend Container App
resource "azurerm_container_app" "frontend_staging" {
  name                         = "campus-connect-frontend-staging"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  template {
    container {
      name   = "frontend-staging"
      image  = "${azurerm_container_registry.main.login_server}/campusconnect-frontend:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "REACT_APP_API_URL"
        value = "https://${azurerm_container_app.backend_staging.latest_revision_fqdn}/api"
      }
      env {
        name  = "REACT_APP_ENVIRONMENT"
        value = "staging"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 80
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

# Staging Database
resource "azurerm_postgresql_database" "staging" {
  name                = "${var.db_name}_staging"
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

output "production_backend_url" {
  value = "https://${azurerm_container_app.backend.latest_revision_fqdn}"
}

output "production_frontend_url" {
  value = "https://${azurerm_container_app.frontend.latest_revision_fqdn}"
}

output "staging_backend_url" {
  value = "https://${azurerm_container_app.backend_staging.latest_revision_fqdn}"
}

output "staging_frontend_url" {
  value = "https://${azurerm_container_app.frontend_staging.latest_revision_fqdn}"
}

output "application_insights_key" {
  value     = azurerm_application_insights.main.instrumentation_key
  sensitive = true
} 