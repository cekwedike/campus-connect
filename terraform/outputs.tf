output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.alb.alb_dns_name
}

output "backend_url" {
  description = "Backend API URL"
  value       = "http://${module.alb.alb_dns_name}/api"
}

output "frontend_url" {
  description = "Frontend application URL"
  value       = "http://${module.alb.alb_dns_name}"
}

output "ecr_repository_urls" {
  description = "ECR repository URLs"
  value       = module.ecr.repository_urls
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = module.rds.db_endpoint
  sensitive   = true
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
} 