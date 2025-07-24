# Azure Deployment Script
Write-Host "🚀 Starting Azure Deployment for CampusConnect" -ForegroundColor Green

# Set Terraform path
$TERRAFORM = "C:\Users\cheed\AppData\Local\Microsoft\WinGet\Packages\Hashicorp.Terraform_Microsoft.Winget.Source_8wekyb3d8bbwe\terraform.exe"

# Check if Terraform exists
if (!(Test-Path $TERRAFORM)) {
    Write-Host "❌ Terraform not found at: $TERRAFORM" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Terraform found at: $TERRAFORM" -ForegroundColor Green

# Check Azure login
Write-Host "🔐 Checking Azure login..." -ForegroundColor Yellow
az account show
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Not logged into Azure. Please run: az login" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Azure login verified" -ForegroundColor Green

# Run Terraform plan
Write-Host "📋 Running Terraform plan..." -ForegroundColor Yellow
& $TERRAFORM plan

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform plan failed" -ForegroundColor Red
    exit 1
}

# Ask for confirmation
Write-Host "⚠️  Do you want to apply these changes? (y/N)" -ForegroundColor Yellow
$response = Read-Host

if ($response -eq "y" -or $response -eq "Y") {
    Write-Host "🚀 Applying Terraform changes..." -ForegroundColor Yellow
    & $TERRAFORM apply -auto-approve
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Terraform apply failed" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "🎉 Infrastructure deployment completed!" -ForegroundColor Green
    
    # Get outputs
    Write-Host "📋 Getting deployment outputs..." -ForegroundColor Yellow
    $ACR_SERVER = & $TERRAFORM output -raw acr_login_server
    $RG_NAME = & $TERRAFORM output -raw resource_group_name
    $BACKEND_URL = & $TERRAFORM output -raw backend_url
    $FRONTEND_URL = & $TERRAFORM output -raw frontend_url
    
    Write-Host "✅ Deployment successful!" -ForegroundColor Green
    Write-Host "📋 Resource Group: $RG_NAME" -ForegroundColor Cyan
    Write-Host "📦 Container Registry: $ACR_SERVER" -ForegroundColor Cyan
    Write-Host "🌐 Frontend URL: $FRONTEND_URL" -ForegroundColor Cyan
    Write-Host "🔗 Backend URL: $BACKEND_URL" -ForegroundColor Cyan
    
} else {
    Write-Host "❌ Deployment cancelled" -ForegroundColor Yellow
} 