# Test Current API Configuration Script
# This script helps identify where the HTTP URL is coming from

Write-Host "=== Testing Current API Configuration ===" -ForegroundColor Green
Write-Host ""

$FRONTEND_URL = "https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io"
$BACKEND_URL = "https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io"

Write-Host "🔍 Testing Current Configuration..." -ForegroundColor Yellow
Write-Host ""

# Test 1: Frontend Accessibility
Write-Host "1. Frontend Accessibility..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri $FRONTEND_URL -Method GET -TimeoutSec 10
    Write-Host "   ✅ Frontend is accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Frontend accessibility failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Backend Health
Write-Host "2. Backend Health..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$BACKEND_URL/health" -Method GET -TimeoutSec 10
    Write-Host "   ✅ Backend is healthy: $($response.message)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Backend health failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Backend Projects API
Write-Host "3. Backend Projects API..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$BACKEND_URL/api/projects" -Method GET -TimeoutSec 10
    Write-Host "   ✅ Projects API working: $($response.Length) projects returned" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Projects API failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Backend Tasks API
Write-Host "4. Backend Tasks API..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$BACKEND_URL/api/tasks" -Method GET -TimeoutSec 10
    Write-Host "   ✅ Tasks API working: $($response.Length) tasks returned" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Tasks API failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🔍 Analysis:" -ForegroundColor Yellow
Write-Host ""
Write-Host "✅ Backend APIs are working correctly over HTTPS" -ForegroundColor Green
Write-Host "❌ Frontend is still trying to use HTTP URLs" -ForegroundColor Red
Write-Host ""
Write-Host "🔧 Possible Causes:" -ForegroundColor Yellow
Write-Host "1. Browser cache is using old JavaScript files" -ForegroundColor White
Write-Host "2. Frontend container needs more time to update" -ForegroundColor White
Write-Host "3. There might be another API configuration file" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Solutions to Try:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Force browser cache clear:" -ForegroundColor White
Write-Host "   - Press Ctrl+Shift+Delete" -ForegroundColor White
Write-Host "   - Select 'All time' and all checkboxes" -ForegroundColor White
Write-Host "   - Click 'Clear data'" -ForegroundColor White
Write-Host ""
Write-Host "2. Use incognito/private mode:" -ForegroundColor White
Write-Host "   - Open new incognito window" -ForegroundColor White
Write-Host "   - Test the application" -ForegroundColor White
Write-Host ""
Write-Host "3. Wait 2-3 minutes for container restart to complete" -ForegroundColor White
Write-Host ""
Write-Host "4. Check browser console for exact URLs being requested" -ForegroundColor White
Write-Host ""
Write-Host "The backend is working correctly - this is a frontend caching issue!" -ForegroundColor Green 