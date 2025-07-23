# Configure AWS Provider
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket = "campus-connect-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "campus-connect"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# VPC and Networking
module "vpc" {
  source = "./modules/vpc"
  
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  azs         = var.availability_zones
}

# ECR Repositories
module "ecr" {
  source = "./modules/ecr"
  
  environment = var.environment
  repositories = [
    "campus-connect-backend",
    "campus-connect-frontend"
  ]
}

# RDS Database
module "rds" {
  source = "./modules/rds"
  
  environment        = var.environment
  vpc_id            = module.vpc.vpc_id
  private_subnets   = module.vpc.private_subnets
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  db_instance_class = var.db_instance_class
}

# ECS Cluster and Services
module "ecs" {
  source = "./modules/ecs"
  
  environment      = var.environment
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  
  backend_image = "${module.ecr.repository_urls["campus-connect-backend"]}:latest"
  frontend_image = "${module.ecr.repository_urls["campus-connect-frontend"]}:latest"
  
  db_endpoint = module.rds.db_endpoint
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
  
  secret_key = var.secret_key
}

# Application Load Balancer
module "alb" {
  source = "./modules/alb"
  
  environment     = var.environment
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  
  backend_target_group_arn = module.ecs.backend_target_group_arn
  frontend_target_group_arn = module.ecs.frontend_target_group_arn
} 