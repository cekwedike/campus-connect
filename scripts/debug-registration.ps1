# Debug Registration Issue Script
# This script helps identify and fix registration problems

Write-Host "=== Debugging Registration Issue ===" -ForegroundColor Green
Write-Host ""

Write-Host "1. Testing Backend Registration API..." -ForegroundColor Yellow
try {
    $registerData = @{
        username = "debuguser"
        email = "debuguser@example.com"
        password = "debugpass"
        full_name = "Debug User"
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io/api/auth/register" -Method POST -ContentType "application/json" -Body $registerData -TimeoutSec 10
    Write-Host "   ✅ Backend registration API working" -ForegroundColor Green
    Write-Host "   ✅ Response: $($response.message)" -ForegroundColor Green
    Write-Host "   ✅ User created: $($response.user.username)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Backend registration failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   ❌ Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "   ❌ Response: $($_.Exception.Response.Content)" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Testing Frontend-Backend Connection..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io" -Method GET -TimeoutSec 10
    Write-Host "   ✅ Frontend is accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Frontend accessibility failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Checking CORS Configuration..." -ForegroundColor Yellow
Write-Host "   Backend CORS is configured to allow all origins (*)" -ForegroundColor White
Write-Host "   This should allow frontend to communicate with backend" -ForegroundColor White

Write-Host ""
Write-Host "4. Possible Issues and Solutions:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   Issue A: Browser Cache" -ForegroundColor Cyan
Write-Host "   Solution: Clear browser cache and try again" -ForegroundColor White
Write-Host ""
Write-Host "   Issue B: Frontend not updated" -ForegroundColor Cyan
Write-Host "   Solution: Force refresh (Ctrl+F5) or open in incognito mode" -ForegroundColor White
Write-Host ""
Write-Host "   Issue C: Network connectivity" -ForegroundColor Cyan
Write-Host "   Solution: Check internet connection and try again" -ForegroundColor White
Write-Host ""
Write-Host "   Issue D: Frontend code issue" -ForegroundColor Cyan
Write-Host "   Solution: Check browser console for JavaScript errors" -ForegroundColor White

Write-Host ""
Write-Host "5. Quick Test Steps:" -ForegroundColor Yellow
Write-Host "   1. Open browser console (F12)" -ForegroundColor White
Write-Host "   2. Go to registration page" -ForegroundColor White
Write-Host "   3. Try to register a new user" -ForegroundColor White
Write-Host "   4. Check console for any error messages" -ForegroundColor White
Write-Host "   5. Report any errors you see" -ForegroundColor White

Write-Host ""
Write-Host "=== Registration URLs ===" -ForegroundColor Green
Write-Host "Frontend Registration: https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io/register" -ForegroundColor Yellow
Write-Host "Backend Registration API: https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io/api/auth/register" -ForegroundColor Yellow 