# Test New Backend
Write-Host "🧪 Testing New Backend" -ForegroundColor Green

$BACKEND_URL = "https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io"

# Test 1: Ping endpoint
Write-Host "`n1. Testing ping endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BACKEND_URL/ping" -Method GET -TimeoutSec 15
    Write-Host "✅ Ping working! Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Ping failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Root endpoint
Write-Host "`n2. Testing root endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BACKEND_URL/" -Method GET -TimeoutSec 15
    Write-Host "✅ Root working! Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Root failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Health endpoint
Write-Host "`n3. Testing health endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BACKEND_URL/health" -Method GET -TimeoutSec 15
    Write-Host "✅ Health working! Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Health failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Database connection
Write-Host "`n4. Testing database connection..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BACKEND_URL/test-db" -Method GET -TimeoutSec 15
    Write-Host "✅ Database test working! Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Database test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Environment info
Write-Host "`n5. Testing environment info..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BACKEND_URL/api/info" -Method GET -TimeoutSec 15
    Write-Host "✅ Info working! Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Info failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Frontend (should work)
Write-Host "`n6. Testing frontend..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io" -Method GET -TimeoutSec 15
    Write-Host "✅ Frontend working! Status: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ Frontend failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎯 Summary:" -ForegroundColor Cyan
Write-Host "Backend URL: $BACKEND_URL" -ForegroundColor Yellow
Write-Host "Frontend URL: https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io" -ForegroundColor Yellow 