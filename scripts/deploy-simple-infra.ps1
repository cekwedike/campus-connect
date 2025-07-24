# Simple Infrastructure Deployment Script
Write-Host "🚀 Starting CampusConnect Simple Infrastructure Deployment" -ForegroundColor Green

# Set Terraform path
$TERRAFORM_PATH = "C:\Users\cheed\AppData\Local\Microsoft\WinGet\Packages\Hashicorp.Terraform_Microsoft.Winget.Source_8wekyb3d8bbwe\terraform.exe"

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
if (Test-Path $TERRAFORM_PATH) {
    Write-Host "✅ Terraform is available" -ForegroundColor Green
} else {
    Write-Host "❌ Terraform is not available at: $TERRAFORM_PATH" -ForegroundColor Red
    exit 1
}

# Show current account
Write-Host "📋 Current Azure account:" -ForegroundColor Yellow
az account show --query "name" --output tsv
az account show --query "id" --output tsv

# Deploy infrastructure
Write-Host "🏗️  Deploying Azure infrastructure..." -ForegroundColor Yellow
Set-Location terraform

# Copy simplified main file
Copy-Item "simple-main.tf" "main.tf" -Force

# Initialize Terraform
Write-Host "🔧 Initializing Terraform..." -ForegroundColor Yellow
& $TERRAFORM_PATH init
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform initialization failed." -ForegroundColor Red
    exit 1
}

# Plan deployment
Write-Host "📋 Planning Terraform deployment..." -ForegroundColor Yellow
& $TERRAFORM_PATH plan
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform plan failed." -ForegroundColor Red
    exit 1
}

# Ask for confirmation
Write-Host "⚠️  Do you want to apply these changes? (y/N)" -ForegroundColor Yellow
$response = Read-Host
if ($response -eq "y" -or $response -eq "Y") {
    Write-Host "🚀 Applying Terraform changes..." -ForegroundColor Yellow
    & $TERRAFORM_PATH apply -auto-approve
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