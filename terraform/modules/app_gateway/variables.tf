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

variable "subnet_id" {
  description = "Subnet ID for Application Gateway"
  type        = string
}

variable "backend_url" {
  description = "Backend application URL"
  type        = string
}

variable "frontend_url" {
  description = "Frontend application URL"
  type        = string
} 