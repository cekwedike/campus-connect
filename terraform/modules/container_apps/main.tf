# Container Apps Environment
resource "azurerm_container_app_environment" "main" {
  name                       = "${var.environment}-campus-connect-env"
  location                   = var.location
  resource_group_name        = var.resource_group_name
}

# Backend Container App
resource "azurerm_container_app" "backend" {
  name                         = "backend-app"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name   = "backend"
      image  = var.backend_image
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "DATABASE_URL"
        value = var.db_connection_string
      }
      env {
        name  = "SECRET_KEY"
        value = var.secret_key
      }
      env {
        name  = "ENVIRONMENT"
        value = "production"
      }
    }

    min_replicas = 1
    max_replicas = 3
  }

  ingress {
    external_enabled = true
    target_port     = 8000
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

# Frontend Container App
resource "azurerm_container_app" "frontend" {
  name                         = "frontend-app"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name   = "frontend"
      image  = var.frontend_image
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "REACT_APP_API_URL"
        value = "https://${azurerm_container_app.backend.latest_revision_fqdn}"
      }
      env {
        name  = "ENVIRONMENT"
        value = "production"
      }
    }

    min_replicas = 1
    max_replicas = 3
  }

  ingress {
    external_enabled = true
    target_port     = 3000
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
} 