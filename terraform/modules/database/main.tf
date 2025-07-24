# Azure Database for PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "main" {
  name                   = "${var.environment}-campus-connect-db"
  resource_group_name    = var.resource_group_name
  location              = var.location
  version               = "14"
  administrator_login   = var.db_username
  administrator_password = var.db_password
  storage_mb            = 32768
  sku_name              = var.db_sku_name
  
  depends_on = [azurerm_private_dns_zone_virtual_network_link.main]
}

# Private DNS Zone for PostgreSQL
resource "azurerm_private_dns_zone" "main" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

# Private DNS Zone VNet Link
resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  name                  = "${var.environment}-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.main.name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = data.azurerm_subnet.main.virtual_network_id
}

# Private Endpoint
resource "azurerm_private_endpoint" "main" {
  name                = "${var.environment}-db-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.environment}-db-connection"
    private_connection_resource_id = azurerm_postgresql_flexible_server.main.id
    is_manual_connection           = false
    subresource_names             = ["postgresqlServer"]
  }

  private_dns_zone_group {
    name                 = "${var.environment}-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.main.id]
  }
}

# Database
resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = var.db_name
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

# Data source for subnet
data "azurerm_subnet" "main" {
  name                 = split("/", var.subnet_id)[10]
  virtual_network_name = split("/", var.subnet_id)[8]
  resource_group_name  = split("/", var.subnet_id)[4]
} 