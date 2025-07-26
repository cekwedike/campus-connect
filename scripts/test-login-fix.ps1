# Test Login Fix Script
# This script verifies that the login functionality is now working

Write-Host "=== Testing Login Fix ===" -ForegroundColor Green
Write-Host ""

$BACKEND_URL = "https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io"
$FRONTEND_URL = "https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io"

Write-Host "1. Testing Backend Health..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$BACKEND_URL/health" -Method GET -TimeoutSec 10
    Write-Host "✅ Backend is healthy: $($response.message)" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend health check failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "2. Testing Backend Root..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$BACKEND_URL/" -Method GET -TimeoutSec 10
    Write-Host "✅ Backend is running: $($response.message)" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend root check failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "3. Testing Login API..." -ForegroundColor Yellow
try {
    $loginData = @{
        email = "test@example.com"
        password = "testpassword"
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$BACKEND_URL/api/auth/login" -Method POST -ContentType "application/json" -Body $loginData -TimeoutSec 10
    Write-Host "✅ Login API working: $($response.message)" -ForegroundColor Green
    Write-Host "   Token received: $($response.access_token.Substring(0, 20))..." -ForegroundColor Cyan
} catch {
    Write-Host "❌ Login API failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "4. Testing Frontend Accessibility..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $FRONTEND_URL -Method GET -TimeoutSec 10
    Write-Host "✅ Frontend is accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ Frontend accessibility failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Login Fix Verification Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "🎉 All systems are working correctly!" -ForegroundColor Green
Write-Host ""
Write-Host "You can now test the login at:" -ForegroundColor Yellow
Write-Host "   $FRONTEND_URL/login" -ForegroundColor White
Write-Host ""
Write-Host "Use these test credentials:" -ForegroundColor Yellow
Write-Host "   Email: test@example.com" -ForegroundColor White
Write-Host "   Password: testpassword" -ForegroundColor White
Write-Host ""
Write-Host "The login should now work without the 'No response from server' error!" -ForegroundColor Green 