#!/bin/bash

# CampusConnect Azure Deployment Script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ACR_NAME=${ACR_NAME:-"productioncampusconnectacr"}
IMAGE_TAG=${IMAGE_TAG:-"latest"}
AZURE_REGION=${AZURE_REGION:-"East US"}

echo -e "${GREEN}🚀 Starting CampusConnect Azure Deployment${NC}"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

# Login to Azure
echo -e "${YELLOW}🔐 Logging into Azure...${NC}"
az login

# Login to ACR
echo -e "${YELLOW}🔐 Logging into Azure Container Registry...${NC}"
az acr login --name $ACR_NAME

# Build and push Backend
echo -e "${YELLOW}🏗️  Building Backend image...${NC}"
docker build -t $ACR_NAME.azurecr.io/campus-connect-backend:$IMAGE_TAG ./backend

echo -e "${YELLOW}📤 Pushing Backend image to ACR...${NC}"
docker push $ACR_NAME.azurecr.io/campus-connect-backend:$IMAGE_TAG

# Build and push Frontend
echo -e "${YELLOW}🏗️  Building Frontend image...${NC}"
docker build -t $ACR_NAME.azurecr.io/campus-connect-frontend:$IMAGE_TAG ./frontend

echo -e "${YELLOW}📤 Pushing Frontend image to ACR...${NC}"
docker push $ACR_NAME.azurecr.io/campus-connect-frontend:$IMAGE_TAG

echo -e "${GREEN}✅ Images successfully pushed to ACR!${NC}"
echo -e "${GREEN}📋 Next steps:${NC}"
echo -e "   1. Run 'terraform apply' to deploy infrastructure"
echo -e "   2. Update Container Apps with new images"
echo -e "   3. Test the application" 