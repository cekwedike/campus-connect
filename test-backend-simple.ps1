# Simple Backend Test
Write-Host "🔍 Testing Backend Status" -ForegroundColor Green

# Check container app status
Write-Host "`n1. Checking container app status..." -ForegroundColor Yellow
$status = az containerapp show --name campus-connect-backend --resource-group campus-connect-rg --query "properties.runningStatus" --output tsv
Write-Host "Status: $status" -ForegroundColor Cyan

# Check latest revision
Write-Host "`n2. Checking latest revision..." -ForegroundColor Yellow
$revision = az containerapp show --name campus-connect-backend --resource-group campus-connect-rg --query "properties.latestRevisionName" --output tsv
Write-Host "Latest Revision: $revision" -ForegroundColor Cyan

# Test with curl (different approach)
Write-Host "`n3. Testing with curl..." -ForegroundColor Yellow
try {
    $result = curl -s -o $null -w "%{http_code}" "https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io/ping" --connect-timeout 10
    Write-Host "Curl Status Code: $result" -ForegroundColor Green
} catch {
    Write-Host "Curl failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test frontend (should work)
Write-Host "`n4. Testing frontend..." -ForegroundColor Yellow
try {
    $result = curl -s -o $null -w "%{http_code}" "https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io" --connect-timeout 10
    Write-Host "Frontend Status Code: $result" -ForegroundColor Green
} catch {
    Write-Host "Frontend failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎯 Summary:" -ForegroundColor Cyan
Write-Host "Backend URL: https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io" -ForegroundColor Yellow
Write-Host "Frontend URL: https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io" -ForegroundColor Yellow 