# Test Database and Backend Connection
Write-Host "🔍 Testing Database and Backend Connection" -ForegroundColor Green

# Test 1: Check if database is accessible
Write-Host "`n1. Testing Database Connection..." -ForegroundColor Yellow
$DB_FQDN = "campus-connect-postgres.postgres.database.azure.com"
$DB_PASSWORD = "YourStrongPassword123!"

Write-Host "Database FQDN: $DB_FQDN" -ForegroundColor Cyan
Write-Host "Testing connection to database..." -ForegroundColor Yellow

# Test 2: Check backend status
Write-Host "`n2. Testing Backend Status..." -ForegroundColor Yellow
$BACKEND_URL = "https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io"

Write-Host "Backend URL: $BACKEND_URL" -ForegroundColor Cyan

# Test 3: Try a simple health check
Write-Host "`n3. Testing Backend Health..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BACKEND_URL/docs" -Method GET -TimeoutSec 10
    Write-Host "✅ Backend is responding! Status: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend is not responding: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Check if we can access the API directly
Write-Host "`n4. Testing API Endpoints..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BACKEND_URL/api/v1/health" -Method GET -TimeoutSec 10
    Write-Host "✅ Health endpoint responding!" -ForegroundColor Green
} catch {
    Write-Host "❌ Health endpoint not available" -ForegroundColor Red
}

# Test 5: Check container logs
Write-Host "`n5. Checking Container Logs..." -ForegroundColor Yellow
try {
    $logs = az containerapp logs show --name campus-connect-backend --resource-group campus-connect-rg --query "[0:5]" --output tsv
    Write-Host "Recent logs:" -ForegroundColor Cyan
    Write-Host $logs -ForegroundColor White
} catch {
    Write-Host "❌ Could not retrieve logs" -ForegroundColor Red
}

Write-Host "`n🔧 Troubleshooting Steps:" -ForegroundColor Yellow
Write-Host "1. The backend might be having database connection issues" -ForegroundColor White
Write-Host "2. Try accessing the frontend URL directly" -ForegroundColor White
Write-Host "3. Check if the database password is correct" -ForegroundColor White
Write-Host "4. The backend might need more time to start up" -ForegroundColor White

Write-Host "`n🌐 Try accessing your frontend:" -ForegroundColor Cyan
Write-Host "https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io" -ForegroundColor White 