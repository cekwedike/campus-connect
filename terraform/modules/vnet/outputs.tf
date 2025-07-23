output "vnet_id" {
  description = "Virtual Network ID"
  value       = azurerm_virtual_network.main.id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = azurerm_subnet.public.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = azurerm_subnet.private.id
}

output "public_nsg_id" {
  description = "Public NSG ID"
  value       = azurerm_network_security_group.public.id
}

output "private_nsg_id" {
  description = "Private NSG ID"
  value       = azurerm_network_security_group.private.id
} 