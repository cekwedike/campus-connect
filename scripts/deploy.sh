#!/bin/bash

# CampusConnect Deployment Script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ECR_REGISTRY=${ECR_REGISTRY:-"your-aws-account.dkr.ecr.region.amazonaws.com"}
IMAGE_TAG=${IMAGE_TAG:-"latest"}
AWS_REGION=${AWS_REGION:-"us-east-1"}

echo -e "${GREEN}🚀 Starting CampusConnect Deployment${NC}"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

# Login to ECR
echo -e "${YELLOW}🔐 Logging into ECR...${NC}"
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

# Build and push Backend
echo -e "${YELLOW}🏗️  Building Backend image...${NC}"
docker build -t $ECR_REGISTRY/campus-connect-backend:$IMAGE_TAG ./backend

echo -e "${YELLOW}📤 Pushing Backend image to ECR...${NC}"
docker push $ECR_REGISTRY/campus-connect-backend:$IMAGE_TAG

# Build and push Frontend
echo -e "${YELLOW}🏗️  Building Frontend image...${NC}"
docker build -t $ECR_REGISTRY/campus-connect-frontend:$IMAGE_TAG ./frontend

echo -e "${YELLOW}📤 Pushing Frontend image to ECR...${NC}"
docker push $ECR_REGISTRY/campus-connect-frontend:$IMAGE_TAG

echo -e "${GREEN}✅ Images successfully pushed to ECR!${NC}"
echo -e "${GREEN}📋 Next steps:${NC}"
echo -e "   1. Run 'terraform apply' to deploy infrastructure"
echo -e "   2. Update ECS services with new images"
echo -e "   3. Test the application" 