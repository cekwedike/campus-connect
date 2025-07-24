# Simple CampusConnect Azure Deployment Script
Write-Host "🚀 Starting CampusConnect Azure Deployment" -ForegroundColor Green

# Check if Azure CLI is available
try {
    $azVersion = az --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Azure CLI is not available. Please restart PowerShell and try again." -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Azure CLI is available" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI is not available. Please restart PowerShell and try again." -ForegroundColor Red
    exit 1
}

# Check if Docker is running
try {
    docker info 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    exit 1
}

# Check if Terraform is available
try {
    terraform --version 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Terraform is not available." -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Terraform is available" -ForegroundColor Green
} catch {
    Write-Host "❌ Terraform is not available." -ForegroundColor Red
    exit 1
}

# Show current account
Write-Host "📋 Current Azure account:" -ForegroundColor Yellow
az account show --query "name" --output tsv
az account show --query "id" --output tsv

# Configure Terraform variables
Write-Host "⚙️  Configuring Terraform variables..." -ForegroundColor Yellow
if (!(Test-Path "terraform\terraform.tfvars")) {
    Copy-Item "terraform\terraform.tfvars.example" "terraform\terraform.tfvars"
    Write-Host "📝 Created terraform.tfvars from example. Please edit it with your values." -ForegroundColor Yellow
    Write-Host "   Important: Change db_password and secret_key to strong values!" -ForegroundColor Yellow
    notepad "terraform\terraform.tfvars"
}

# Deploy infrastructure
Write-Host "🏗️  Deploying Azure infrastructure..." -ForegroundColor Yellow
Set-Location terraform

# Initialize Terraform
Write-Host "🔧 Initializing Terraform..." -ForegroundColor Yellow
terraform init
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform initialization failed." -ForegroundColor Red
    exit 1
}

# Plan deployment
Write-Host "📋 Planning Terraform deployment..." -ForegroundColor Yellow
terraform plan
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform plan failed." -ForegroundColor Red
    exit 1
}

# Ask for confirmation
Write-Host "⚠️  Do you want to apply these changes? (y/N)" -ForegroundColor Yellow
$response = Read-Host
if ($response -eq "y" -or $response -eq "Y") {
    Write-Host "🚀 Applying Terraform changes..." -ForegroundColor Yellow
    terraform apply -auto-approve
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Terraform apply failed." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "❌ Deployment cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host "🎉 Infrastructure deployment completed!" -ForegroundColor Green
Write-Host "📋 Next steps:" -ForegroundColor Green
Write-Host "   1. Build and push Docker images" -ForegroundColor Yellow
Write-Host "   2. Deploy applications to Container Apps" -ForegroundColor Yellow
Write-Host "   3. Test the application" -ForegroundColor Yellow 