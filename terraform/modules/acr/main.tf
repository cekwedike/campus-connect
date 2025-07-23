# Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = "${var.environment}campusconnectacr"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = {
    Name = "${var.environment}-acr"
  }
}

# ACR Lifecycle Policy
resource "azurerm_container_registry_task" "cleanup" {
  name                  = "cleanup-task"
  container_registry_id = azurerm_container_registry.main.id
  platform {
    os = "Linux"
  }

  encoded_step {
    task_content = base64encode(<<EOF
version: v1.1.0
steps:
- cmd: acr purge --filter 'campus-connect-backend:.*' --ago 30d --untagged
- cmd: acr purge --filter 'campus-connect-frontend:.*' --ago 30d --untagged
EOF
    )
  }

  timer_trigger {
    schedule = "0 0 * * *"  # Daily at midnight
  }
} 