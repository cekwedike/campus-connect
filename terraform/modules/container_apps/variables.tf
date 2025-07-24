variable "environment" {
  description = "Environment name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "backend_image" {
  description = "Backend container image"
  type        = string
}

variable "frontend_image" {
  description = "Frontend container image"
  type        = string
}

variable "db_connection_string" {
  description = "Database connection string"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "Application secret key"
  type        = string
  sensitive   = true
} 