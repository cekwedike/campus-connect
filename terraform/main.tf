# Configure Azure Provider
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  # Using local state for now
  # backend "azurerm" {
  #   resource_group_name  = "campus-connect-terraform-rg"
  #   storage_account_name = "campusconnecttfstate"
  #   container_name       = "terraform-state"
  #   key                  = "terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.environment}-campus-connect-rg"
  location = var.location
}

# Virtual Network
module "vnet" {
  source = "./modules/vnet"
  
  environment = var.environment
  location    = var.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.vnet_address_space
}

# Container Registry
module "acr" {
  source = "./modules/acr"
  
  environment = var.environment
  location    = var.location
  resource_group_name = azurerm_resource_group.main.name
  repositories = [
    "campus-connect-backend",
    "campus-connect-frontend"
  ]
}

# Database
module "database" {
  source = "./modules/database"
  
  environment = var.environment
  location    = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id          = module.vnet.private_subnet_id
  
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
  db_sku_name = var.db_sku_name
}

# Container Apps
module "container_apps" {
  source = "./modules/container_apps"
  
  environment = var.environment
  location    = var.location
  resource_group_name = azurerm_resource_group.main.name
  
  backend_image = "${module.acr.login_server}/campus-connect-backend:latest"
  frontend_image = "${module.acr.login_server}/campus-connect-frontend:latest"
  
  db_connection_string = module.database.connection_string
  secret_key = var.secret_key
  
  depends_on = [module.acr, module.database]
}

# Application Gateway
module "app_gateway" {
  source = "./modules/app_gateway"
  
  environment = var.environment
  location    = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id          = module.vnet.public_subnet_id
  
  backend_url = module.container_apps.backend_url
  frontend_url = module.container_apps.frontend_url
} 