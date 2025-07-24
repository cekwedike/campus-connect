# Show All Azure Resources
Write-Host "🔍 Showing All Your Azure Resources" -ForegroundColor Green

Write-Host "`n📋 Your Resources Summary:" -ForegroundColor Cyan
Write-Host "Total Resources: 8" -ForegroundColor White
Write-Host "Resource Group: campus-connect-rg" -ForegroundColor White

Write-Host "`n📦 Your Deployed Resources:" -ForegroundColor Yellow

# List all resources with details
$resources = az resource list --output json | ConvertFrom-Json

foreach ($resource in $resources) {
    if ($resource.resourceGroup -eq "campus-connect-rg") {
        $status = "✅"
        $color = "Green"
    } else {
        $status = "ℹ️"
        $color = "Gray"
    }
    
    Write-Host "$status $($resource.name)" -ForegroundColor $color
    Write-Host "   Type: $($resource.type)" -ForegroundColor White
    Write-Host "   Location: $($resource.location)" -ForegroundColor White
    Write-Host "   Resource Group: $($resource.resourceGroup)" -ForegroundColor White
    Write-Host ""
}

Write-Host "`n🌐 How to See These in Azure Portal:" -ForegroundColor Cyan
Write-Host "1. Go to https://portal.azure.com" -ForegroundColor White
Write-Host "2. Click 'Resource groups' in the left menu" -ForegroundColor White
Write-Host "3. Click on 'campus-connect-rg'" -ForegroundColor White
Write-Host "4. You'll see all your resources listed!" -ForegroundColor White

Write-Host "`n🔗 Direct Links:" -ForegroundColor Cyan
Write-Host "Resource Group: https://portal.azure.com/#@cheediwritesgmail.onmicrosoft.com/resource/subscriptions/f397a1ba-b784-4858-b6c6-dce6980197f8/resourceGroups/campus-connect-rg" -ForegroundColor White

Write-Host "`n📸 For Your Assignment Screenshots:" -ForegroundColor Yellow
Write-Host "Take screenshots of:" -ForegroundColor White
Write-Host "1. The Resource Group page showing all 8 resources" -ForegroundColor White
Write-Host "2. Individual resource pages (Container Registry, Container Apps, Database)" -ForegroundColor White
Write-Host "3. The Container Apps showing your running applications" -ForegroundColor White

Write-Host "`n🎯 Your Application URLs:" -ForegroundColor Cyan
Write-Host "Frontend: https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io" -ForegroundColor White
Write-Host "Backend: https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io" -ForegroundColor White 