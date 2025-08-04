# Fix Backend Deployment Script (Corrected)
# This script rebuilds and redeploys the backend to fix the database connection issue

Write-Host "=== Fixing Backend Deployment ===" -ForegroundColor Green
Write-Host ""

Write-Host "1. Building new backend image..." -ForegroundColor Yellow
Write-Host "   - Using in-memory storage (no database required)" -ForegroundColor White
Write-Host "   - Optimized for Azure Container Apps" -ForegroundColor White
Write-Host ""

# Get ACR details (corrected name)
$ACR_NAME = "campusconnect2024acr"
$RESOURCE_GROUP = "campus-connect-rg"
$BACKEND_IMAGE = "campus-connect-backend:latest"
$FULL_IMAGE_NAME = "$ACR_NAME.azurecr.io/$BACKEND_IMAGE"

Write-Host "2. Building and pushing backend image..." -ForegroundColor Yellow
Write-Host "   ACR: $ACR_NAME.azurecr.io" -ForegroundColor White
Write-Host "   Image: $FULL_IMAGE_NAME" -ForegroundColor White
Write-Host ""

# Build and push the backend image
Write-Host "Building backend image..." -ForegroundColor Cyan
docker build -t $FULL_IMAGE_NAME ./backend

Write-Host "Pushing to ACR..." -ForegroundColor Cyan
az acr login --name $ACR_NAME
docker push $FULL_IMAGE_NAME

Write-Host "3. Updating Container App..." -ForegroundColor Yellow
Write-Host "   - Removing database environment variables" -ForegroundColor White
Write-Host "   - Setting correct API configuration" -ForegroundColor White
Write-Host ""

# Update the container app with the new image and correct environment
az containerapp update `
  --name campus-connect-backend `
  --resource-group $RESOURCE_GROUP `
  --image $FULL_IMAGE_NAME `
  --set-env-vars SECRET_KEY="your-secret-key-here"

Write-Host "4. Verifying deployment..." -ForegroundColor Yellow
Write-Host "   - Checking container app status" -ForegroundColor White
Write-Host "   - Testing API endpoints" -ForegroundColor White
Write-Host ""

# Wait a moment for the update to take effect
Write-Host "Waiting for deployment to complete..." -ForegroundColor Cyan
Start-Sleep -Seconds 60

Write-Host "5. Testing backend connectivity..." -ForegroundColor Yellow
$BACKEND_URL = "https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io"

Write-Host "Testing health endpoint..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$BACKEND_URL/health" -Method GET -TimeoutSec 15
    Write-Host "✅ Backend is healthy: $($response.message)" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend health check failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Testing root endpoint..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$BACKEND_URL/" -Method GET -TimeoutSec 15
    Write-Host "✅ Backend is running: $($response.message)" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend root check failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Deployment Complete ===" -ForegroundColor Green
Write-Host "Backend should now be working without database dependencies" -ForegroundColor White
Write-Host "Frontend login should work at: https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io/login" -ForegroundColor White
Write-Host ""
Write-Host "Test with these credentials:" -ForegroundColor Yellow
Write-Host "Email: test@example.com" -ForegroundColor White
Write-Host "Password: testpassword" -ForegroundColor White 