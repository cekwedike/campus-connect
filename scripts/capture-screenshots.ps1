# Azure Resource Screenshot Capture Script
# This script helps you capture screenshots of your deployed Azure resources

Write-Host "=== Azure Resource Screenshot Guide ===" -ForegroundColor Green
Write-Host ""

Write-Host "1. Azure Portal Resource Group Screenshot:" -ForegroundColor Yellow
Write-Host "   - Go to: https://portal.azure.com"
Write-Host "   - Navigate to Resource Groups"
Write-Host "   - Click on 'campus-connect-rg'"
Write-Host "   - Take a screenshot showing all resources"
Write-Host ""

Write-Host "2. Container Registry Screenshot:" -ForegroundColor Yellow
Write-Host "   - In the resource group, click on 'campusconnectacr'"
Write-Host "   - Go to 'Repositories' tab"
Write-Host "   - Take a screenshot showing your pushed images"
Write-Host ""

Write-Host "3. Container Apps Screenshot:" -ForegroundColor Yellow
Write-Host "   - In the resource group, click on 'campus-connect-env'"
Write-Host "   - Go to 'Container Apps'"
Write-Host "   - Take screenshots of both frontend and backend apps"
Write-Host ""

Write-Host "4. Database Screenshot:" -ForegroundColor Yellow
Write-Host "   - In the resource group, click on 'campus-connect-db'"
Write-Host "   - Go to 'Overview' tab"
Write-Host "   - Take a screenshot showing the database status"
Write-Host ""

Write-Host "5. Application Screenshots:" -ForegroundColor Yellow
Write-Host "   - Frontend: https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io"
Write-Host "   - Backend: https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io"
Write-Host "   - Take screenshots of both applications running"
Write-Host ""

Write-Host "6. Terraform Output Screenshot:" -ForegroundColor Yellow
Write-Host "   - Run: terraform output"
Write-Host "   - Take a screenshot of the output showing all resource details"
Write-Host ""

Write-Host "=== Instructions for Adding Screenshots to phase.md ===" -ForegroundColor Green
Write-Host ""
Write-Host "1. Save all screenshots in a 'screenshots' folder"
Write-Host "2. Update the 'Deployment Screenshots' section in phase.md"
Write-Host "3. Add descriptions for each screenshot"
Write-Host "4. Ensure screenshots show successful deployment"
Write-Host ""

Write-Host "=== Quick Commands ===" -ForegroundColor Green
Write-Host ""

Write-Host "Get Resource Group Details:" -ForegroundColor Cyan
Write-Host "az group show --name campus-connect-rg --output table"
Write-Host ""

Write-Host "List Container Apps:" -ForegroundColor Cyan
Write-Host "az containerapp list --resource-group campus-connect-rg --output table"
Write-Host ""

Write-Host "Get Container Registry Details:" -ForegroundColor Cyan
Write-Host "az acr show --name campusconnectacr --resource-group campus-connect-rg --output table"
Write-Host ""

Write-Host "Get Database Details:" -ForegroundColor Cyan
Write-Host "az postgres server show --name campus-connect-db --resource-group campus-connect-rg --output table"
Write-Host ""

Write-Host "=== Ready for Screenshots! ===" -ForegroundColor Green 