# Public IP for Application Gateway
resource "azurerm_public_ip" "main" {
  name                = "${var.environment}-app-gateway-ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Application Gateway
resource "azurerm_application_gateway" "main" {
  name                = "${var.environment}-app-gateway"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.main.id
  }

  backend_address_pool {
    name = "backend-pool"
    fqdn_list = [replace(var.backend_url, "https://", "")]
  }

  backend_address_pool {
    name = "frontend-pool"
    fqdn_list = [replace(var.frontend_url, "https://", "")]
  }

  backend_http_settings {
    name                  = "backend-settings"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 60
  }

  backend_http_settings {
    name                  = "frontend-settings"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 60
  }

  http_listener {
    name                           = "backend-listener"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  http_listener {
    name                           = "frontend-listener"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "backend-rule"
    rule_type                  = "Basic"
    http_listener_name         = "backend-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "backend-settings"
    priority                   = 100
  }

  request_routing_rule {
    name                       = "frontend-rule"
    rule_type                  = "Basic"
    http_listener_name         = "frontend-listener"
    backend_address_pool_name  = "frontend-pool"
    backend_http_settings_name = "frontend-settings"
    priority                   = 200
  }
} 