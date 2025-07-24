# Complete Azure Deployment Script
Write-Host "🚀 Completing Azure Deployment for CampusConnect" -ForegroundColor Green

# Set Terraform path
$TERRAFORM = "C:\Users\cheed\AppData\Local\Microsoft\WinGet\Packages\Hashicorp.Terraform_Microsoft.Winget.Source_8wekyb3d8bbwe\terraform.exe"

Write-Host "Step 1: Checking current status..." -ForegroundColor Yellow
& $TERRAFORM plan

Write-Host "`nStep 2: Do you want to apply the deployment? (y/N)" -ForegroundColor Yellow
$response = Read-Host

if ($response -eq "y" -or $response -eq "Y") {
    Write-Host "`nStep 3: Applying deployment..." -ForegroundColor Yellow
    & $TERRAFORM apply -auto-approve
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Deployment successful!" -ForegroundColor Green
        
        Write-Host "`nStep 4: Getting deployment outputs..." -ForegroundColor Yellow
        $ACR_SERVER = & $TERRAFORM output -raw acr_login_server
        $RG_NAME = & $TERRAFORM output -raw resource_group_name
        
        Write-Host "📦 Container Registry: $ACR_SERVER" -ForegroundColor Cyan
        Write-Host "📋 Resource Group: $RG_NAME" -ForegroundColor Cyan
        
        Write-Host "`nStep 5: Ready to push Docker images!" -ForegroundColor Green
        Write-Host "Next commands to run:" -ForegroundColor Yellow
        Write-Host "az acr login --name $($ACR_SERVER.Split('.')[0])" -ForegroundColor White
        Write-Host "docker tag campus-connect-backend:latest `"$ACR_SERVER/campus-connect-backend:latest`"" -ForegroundColor White
        Write-Host "docker push `"$ACR_SERVER/campus-connect-backend:latest`"" -ForegroundColor White
        
    } else {
        Write-Host "❌ Deployment failed" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Deployment cancelled" -ForegroundColor Yellow
} 