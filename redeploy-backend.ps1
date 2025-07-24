# Rebuild and Redeploy Backend
Write-Host "🔧 Rebuilding and Redeploying Backend" -ForegroundColor Green

# Step 1: Build the backend image again
Write-Host "`n1. Building backend Docker image..." -ForegroundColor Yellow
docker-compose build backend

# Step 2: Tag and push the new image
Write-Host "`n2. Tagging and pushing new image..." -ForegroundColor Yellow
docker tag campus-connect-backend:latest campusconnect2024acr.azurecr.io/campus-connect-backend:latest
docker push campusconnect2024acr.azurecr.io/campus-connect-backend:latest

# Step 3: Update the backend with a simple configuration
Write-Host "`n3. Updating backend configuration..." -ForegroundColor Yellow
az containerapp update `
    --name campus-connect-backend `
    --resource-group campus-connect-rg `
    --set-env-vars "DATABASE_URL=sqlite:///./campus_connect.db" "SECRET_KEY=1234567890ekwedike" "ENVIRONMENT=production" "CORS_ORIGINS=https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io"

# Step 4: Wait for the update to complete
Write-Host "`n4. Waiting for backend to restart..." -ForegroundColor Yellow
Start-Sleep -Seconds 120

# Step 5: Test the backend
Write-Host "`n5. Testing backend..." -ForegroundColor Yellow
$BACKEND_URL = "https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io"

try {
    $response = Invoke-WebRequest -Uri "$BACKEND_URL/docs" -Method GET -TimeoutSec 20
    Write-Host "✅ Backend is working! Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "🎉 Your application should now be fully functional!" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend is still not responding: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Let's try one more approach..." -ForegroundColor Yellow
}

Write-Host "`n🌐 Your Application URLs:" -ForegroundColor Cyan
Write-Host "Frontend: https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io" -ForegroundColor White
Write-Host "Backend: $BACKEND_URL" -ForegroundColor White

Write-Host "`n💡 Try accessing the frontend URL now!" -ForegroundColor Yellow
Write-Host "The frontend should work even if the backend is having issues." -ForegroundColor White 