#!/bin/bash

# CampusConnect Azure Terraform Deployment Script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
TF_DIR="./terraform"
TF_VARS_FILE="terraform.tfvars"

echo -e "${GREEN}🏗️  Starting CampusConnect Azure Infrastructure Deployment${NC}"

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if Azure CLI is configured
if ! az account show &> /dev/null; then
    echo -e "${RED}❌ Azure CLI is not configured. Please run 'az login' first.${NC}"
    exit 1
fi

# Navigate to Terraform directory
cd $TF_DIR

# Initialize Terraform
echo -e "${YELLOW}🔧 Initializing Terraform...${NC}"
terraform init

# Plan the deployment
echo -e "${YELLOW}📋 Planning Terraform deployment...${NC}"
terraform plan -var-file=$TF_VARS_FILE

# Ask for confirmation
echo -e "${YELLOW}⚠️  Do you want to apply these changes? (y/N)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${YELLOW}🚀 Applying Terraform changes...${NC}"
    terraform apply -var-file=$TF_VARS_FILE -auto-approve
    
    echo -e "${GREEN}✅ Infrastructure deployed successfully!${NC}"
    echo -e "${GREEN}📋 Outputs:${NC}"
    terraform output
    
    echo -e "${GREEN}🎉 Your CampusConnect application is now deployed!${NC}"
    echo -e "${GREEN}🌐 Frontend URL: $(terraform output -raw frontend_url)${NC}"
    echo -e "${GREEN}🔗 Backend URL: $(terraform output -raw backend_url)${NC}"
else
    echo -e "${YELLOW}❌ Deployment cancelled.${NC}"
    exit 0
fi 