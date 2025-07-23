# CampusConnect Azure Deployment Script
# This script automates the deployment process to Azure

param(
    [string]$SubscriptionId = "",
    [string]$Location = "East US",
    [string]$Environment = "production"
)

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

Write-ColorOutput "🚀 Starting CampusConnect Azure Deployment" $Green

# Check if Azure CLI is available
try {
    $azVersion = az --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "❌ Azure CLI is not available. Please restart PowerShell and try again." $Red
        exit 1
    }
    Write-ColorOutput "✅ Azure CLI is available" $Green
} catch {
    Write-ColorOutput "❌ Azure CLI is not available. Please restart PowerShell and try again." $Red
    exit 1
}

# Check if Docker is running
try {
    docker info 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "❌ Docker is not running. Please start Docker Desktop first." $Red
        exit 1
    }
    Write-ColorOutput "✅ Docker is running" $Green
} catch {
    Write-ColorOutput "❌ Docker is not running. Please start Docker Desktop first." $Red
    exit 1
}

# Check if Terraform is available
try {
    terraform --version 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "❌ Terraform is not available." $Red
        exit 1
    }
    Write-ColorOutput "✅ Terraform is available" $Green
} catch {
    Write-ColorOutput "❌ Terraform is not available." $Red
    exit 1
}

# Login to Azure
Write-ColorOutput "🔐 Logging into Azure..." $Yellow
az login
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "❌ Failed to login to Azure." $Red
    exit 1
}

# Set subscription if provided
if ($SubscriptionId) {
    Write-ColorOutput "📋 Setting subscription to: $SubscriptionId" $Yellow
    az account set --subscription $SubscriptionId
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "❌ Failed to set subscription." $Red
        exit 1
    }
}

# Show current account
Write-ColorOutput "📋 Current Azure account:" $Yellow
az account show --query "{Name:name, SubscriptionId:id, TenantId:tenantId}" --output table

# Configure Terraform variables
Write-ColorOutput "⚙️  Configuring Terraform variables..." $Yellow
if (!(Test-Path "terraform\terraform.tfvars")) {
    Copy-Item "terraform\terraform.tfvars.example" "terraform\terraform.tfvars"
    Write-ColorOutput "📝 Created terraform.tfvars from example. Please edit it with your values." $Yellow
    Write-ColorOutput "   Important: Change db_password and secret_key to strong values!" $Yellow
    notepad "terraform\terraform.tfvars"
}

# Deploy infrastructure
Write-ColorOutput "🏗️  Deploying Azure infrastructure..." $Yellow
Set-Location terraform

# Initialize Terraform
Write-ColorOutput "🔧 Initializing Terraform..." $Yellow
terraform init
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "❌ Terraform initialization failed." $Red
    exit 1
}

# Plan deployment
Write-ColorOutput "📋 Planning Terraform deployment..." $Yellow
terraform plan
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "❌ Terraform plan failed." $Red
    exit 1
}

# Ask for confirmation
Write-ColorOutput "⚠️  Do you want to apply these changes? (y/N)" $Yellow
$response = Read-Host
if ($response -eq "y" -or $response -eq "Y") {
    Write-ColorOutput "🚀 Applying Terraform changes..." $Yellow
    terraform apply -auto-approve
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "❌ Terraform apply failed." $Red
        exit 1
    }
} else {
    Write-ColorOutput "❌ Deployment cancelled." $Yellow
    exit 0
}

# Get outputs
$ACR_SERVER = terraform output -raw acr_login_server
$RG_NAME = terraform output -raw resource_group_name

Set-Location ..

# Login to ACR
Write-ColorOutput "🔐 Logging into Azure Container Registry..." $Yellow
az acr login --name $ACR_SERVER.Split('.')[0]
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "❌ Failed to login to ACR." $Red
    exit 1
}

# Build and push images
Write-ColorOutput "🏗️  Building and pushing Docker images..." $Yellow

# Backend
Write-ColorOutput "📦 Building Backend image..." $Yellow
docker build -t "$ACR_SERVER/campus-connect-backend:latest" ./backend
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "❌ Backend build failed." $Red
    exit 1
}

Write-ColorOutput "📤 Pushing Backend image..." $Yellow
docker push "$ACR_SERVER/campus-connect-backend:latest"
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "❌ Backend push failed." $Red
    exit 1
}

# Frontend
Write-ColorOutput "📦 Building Frontend image..." $Yellow
docker build -t "$ACR_SERVER/campus-connect-frontend:latest" ./frontend
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "❌ Frontend build failed." $Red
    exit 1
}

Write-ColorOutput "📤 Pushing Frontend image..." $Yellow
docker push "$ACR_SERVER/campus-connect-frontend:latest"
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "❌ Frontend push failed." $Red
    exit 1
}

# Update Container Apps
Write-ColorOutput "🔄 Updating Container Apps..." $Yellow

# Update backend
az containerapp update --name backend-app --resource-group $RG_NAME --image "$ACR_SERVER/campus-connect-backend:latest"
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "❌ Backend Container App update failed." $Red
    exit 1
}

# Update frontend
az containerapp update --name frontend-app --resource-group $RG_NAME --image "$ACR_SERVER/campus-connect-frontend:latest"
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "❌ Frontend Container App update failed." $Red
    exit 1
}

# Get application URLs
Write-ColorOutput "🎉 Deployment completed successfully!" $Green
Write-ColorOutput "📋 Application URLs:" $Green

$APP_GATEWAY_URL = terraform -chdir=terraform output -raw app_gateway_url
Write-ColorOutput "🌐 Frontend: http://$APP_GATEWAY_URL" $Green
Write-ColorOutput "🔗 Backend: http://$APP_GATEWAY_URL/api" $Green
Write-ColorOutput "📚 API Docs: http://$APP_GATEWAY_URL/api/docs" $Green

Write-ColorOutput "📋 Next steps:" $Green
Write-ColorOutput "   1. Wait 2-3 minutes for Container Apps to start" $Yellow
Write-ColorOutput "   2. Test the application URLs" $Yellow
Write-ColorOutput "   3. Create a test user account" $Yellow
Write-ColorOutput "   4. Monitor logs if needed: az containerapp logs show --name backend-app --resource-group $RG_NAME" $Yellow 