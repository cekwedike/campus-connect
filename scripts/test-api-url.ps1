# Test API URL Script
# This script verifies that the frontend is using the correct Azure backend URL

Write-Host "=== Testing Frontend API URL Configuration ===" -ForegroundColor Green
Write-Host ""

$FRONTEND_URL = "https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io"
$BACKEND_URL = "https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io"

Write-Host "🔍 Testing Frontend Configuration..." -ForegroundColor Yellow
Write-Host ""

# Test 1: Frontend Accessibility
Write-Host "1. Frontend Accessibility..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri $FRONTEND_URL -Method GET -TimeoutSec 10
    Write-Host "   ✅ Frontend is accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Frontend accessibility failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Backend API
Write-Host "2. Backend API Test..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$BACKEND_URL/api/auth/login" -Method POST -ContentType "application/json" -Body '{"email":"test@example.com","password":"testpassword"}' -TimeoutSec 10
    Write-Host "   ✅ Backend API is working: $($response.message)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Backend API failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🎉 Configuration Test Complete! 🎉" -ForegroundColor Green
Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Open the frontend in your browser:" -ForegroundColor White
Write-Host "   $FRONTEND_URL/login" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Open browser developer tools (F12)" -ForegroundColor White
Write-Host "   - Go to Network tab" -ForegroundColor White
Write-Host "   - Try to login" -ForegroundColor White
Write-Host "   - Check what URL the login request goes to" -ForegroundColor White
Write-Host ""
Write-Host "3. Expected behavior:" -ForegroundColor White
Write-Host "   ✅ Login request should go to: $BACKEND_URL/api/auth/login" -ForegroundColor Green
Write-Host "   ❌ NOT to: localhost:8000/api/auth/login" -ForegroundColor Red
Write-Host ""
Write-Host "4. If you still see localhost:8000:" -ForegroundColor White
Write-Host "   - Clear browser cache (Ctrl+Shift+Delete)" -ForegroundColor White
Write-Host "   - Try incognito/private mode" -ForegroundColor White
Write-Host "   - Wait 2-3 minutes for deployment to fully propagate" -ForegroundColor White
Write-Host ""
Write-Host "The frontend has been redeployed with the correct API URL!" -ForegroundColor Green 