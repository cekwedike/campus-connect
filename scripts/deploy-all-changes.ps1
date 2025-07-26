# Deploy All Changes Script
# This script rebuilds and redeploys both frontend and backend with all recent changes

Write-Host "=== Deploying All Changes to Azure ===" -ForegroundColor Green
Write-Host ""

# Configuration
$ACR_NAME = "campusconnect2024acr"
$RESOURCE_GROUP = "campus-connect-rg"
$BACKEND_IMAGE = "campus-connect-backend:latest"
$FRONTEND_IMAGE = "campus-connect-frontend:latest"
$BACKEND_FULL_IMAGE = "$ACR_NAME.azurecr.io/$BACKEND_IMAGE"
$FRONTEND_FULL_IMAGE = "$ACR_NAME.azurecr.io/$FRONTEND_IMAGE"

Write-Host "1. Logging into Azure Container Registry..." -ForegroundColor Yellow
az acr login --name $ACR_NAME
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to login to ACR" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Successfully logged into ACR" -ForegroundColor Green

Write-Host ""
Write-Host "2. Building and pushing BACKEND image..." -ForegroundColor Yellow
Write-Host "   Image: $BACKEND_FULL_IMAGE" -ForegroundColor White

# Build backend image
Write-Host "   Building backend Docker image..." -ForegroundColor Cyan
docker build -t $BACKEND_FULL_IMAGE ./backend
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Backend build failed" -ForegroundColor Red
    exit 1
}

# Push backend image
Write-Host "   Pushing backend image to ACR..." -ForegroundColor Cyan
docker push $BACKEND_FULL_IMAGE
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Backend push failed" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Backend image built and pushed successfully" -ForegroundColor Green

Write-Host ""
Write-Host "3. Building and pushing FRONTEND image..." -ForegroundColor Yellow
Write-Host "   Image: $FRONTEND_FULL_IMAGE" -ForegroundColor White

# Build frontend image
Write-Host "   Building frontend Docker image..." -ForegroundColor Cyan
docker build -t $FRONTEND_FULL_IMAGE ./frontend
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Frontend build failed" -ForegroundColor Red
    exit 1
}

# Push frontend image
Write-Host "   Pushing frontend image to ACR..." -ForegroundColor Cyan
docker push $FRONTEND_FULL_IMAGE
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Frontend push failed" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Frontend image built and pushed successfully" -ForegroundColor Green

Write-Host ""
Write-Host "4. Updating BACKEND Container App..." -ForegroundColor Yellow
Write-Host "   - Deploying new backend image" -ForegroundColor White
Write-Host "   - Setting correct environment variables" -ForegroundColor White

# Update backend container app
az containerapp update `
  --name campus-connect-backend `
  --resource-group $RESOURCE_GROUP `
  --image $BACKEND_FULL_IMAGE `
  --set-env-vars SECRET_KEY="your-secret-key-here"
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Backend container app update failed" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Backend container app updated successfully" -ForegroundColor Green

Write-Host ""
Write-Host "5. Updating FRONTEND Container App..." -ForegroundColor Yellow
Write-Host "   - Deploying new frontend image" -ForegroundColor White
Write-Host "   - Setting correct API URL" -ForegroundColor White

# Update frontend container app
az containerapp update `
  --name campus-connect-frontend `
  --resource-group $RESOURCE_GROUP `
  --image $FRONTEND_FULL_IMAGE `
  --set-env-vars REACT_APP_API_URL="https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io/api"
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Frontend container app update failed" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Frontend container app updated successfully" -ForegroundColor Green

Write-Host ""
Write-Host "6. Waiting for deployments to complete..." -ForegroundColor Yellow
Write-Host "   This may take 2-3 minutes..." -ForegroundColor White
Start-Sleep -Seconds 120

Write-Host ""
Write-Host "7. Testing the deployment..." -ForegroundColor Yellow

$BACKEND_URL = "https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io"
$FRONTEND_URL = "https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io"

# Test backend
Write-Host "   Testing backend health..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$BACKEND_URL/health" -Method GET -TimeoutSec 15
    Write-Host "   ✅ Backend is healthy: $($response.message)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Backend health check failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test login API
Write-Host "   Testing login API..." -ForegroundColor Cyan
try {
    $loginData = @{
        email = "test@example.com"
        password = "testpassword"
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$BACKEND_URL/api/auth/login" -Method POST -ContentType "application/json" -Body $loginData -TimeoutSec 15
    Write-Host "   ✅ Login API working: $($response.message)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Login API failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test frontend
Write-Host "   Testing frontend accessibility..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri $FRONTEND_URL -Method GET -TimeoutSec 15
    Write-Host "   ✅ Frontend is accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Frontend accessibility failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Deployment Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "🎉 All changes have been deployed to Azure!" -ForegroundColor Green
Write-Host ""
Write-Host "Your application is now live at:" -ForegroundColor Yellow
Write-Host "   Frontend: $FRONTEND_URL" -ForegroundColor White
Write-Host "   Backend: $BACKEND_URL" -ForegroundColor White
Write-Host ""
Write-Host "Login URL: $FRONTEND_URL/login" -ForegroundColor Yellow
Write-Host ""
Write-Host "Test credentials:" -ForegroundColor Yellow
Write-Host "   Email: test@example.com" -ForegroundColor White
Write-Host "   Password: testpassword" -ForegroundColor White
Write-Host ""
Write-Host "The login and registration should now work correctly!" -ForegroundColor Green 