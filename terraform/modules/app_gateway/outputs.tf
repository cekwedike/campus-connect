output "public_ip_address" {
  description = "Application Gateway public IP address"
  value       = azurerm_public_ip.main.ip_address
}

output "gateway_url" {
  description = "Application Gateway URL"
  value       = "http://${azurerm_public_ip.main.ip_address}"
} 