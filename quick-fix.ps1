# Quick Fix for Backend Issues
Write-Host "🔧 Quick Fix for Backend Issues" -ForegroundColor Yellow

# Update backend with proper environment variables
Write-Host "Updating backend configuration..." -ForegroundColor Green

az containerapp update `
    --name campus-connect-backend `
    --resource-group campus-connect-rg `
    --set-env-vars "DATABASE_URL=sqlite:///./campus_connect.db" "SECRET_KEY=1234567890ekwedike" "ENVIRONMENT=production" "CORS_ORIGINS=https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io"

Write-Host "✅ Backend configuration updated!" -ForegroundColor Green

# Wait for the update to complete
Write-Host "Waiting for backend to restart..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

# Test the backend
Write-Host "Testing backend..." -ForegroundColor Yellow
$response = curl -s -o $null -w "%{http_code}" https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io/docs

if ($response -eq "200") {
    Write-Host "✅ Backend is working! HTTP Status: $response" -ForegroundColor Green
} else {
    Write-Host "⚠️ Backend might still be starting. HTTP Status: $response" -ForegroundColor Yellow
}

Write-Host "`n🎯 Try accessing your application now:" -ForegroundColor Cyan
Write-Host "Frontend: https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io" -ForegroundColor White
Write-Host "Backend API: https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io" -ForegroundColor White 