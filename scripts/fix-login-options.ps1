# Fix Login Options Script
# This script gives you options to choose between email or username login

Write-Host "=== Login Configuration Options ===" -ForegroundColor Green
Write-Host ""

Write-Host "Current Setup:" -ForegroundColor Yellow
Write-Host "   Login uses: EMAIL" -ForegroundColor White
Write-Host "   Registration: Collects username, email, password, full_name" -ForegroundColor White
Write-Host ""

Write-Host "Options:" -ForegroundColor Yellow
Write-Host "1. Keep EMAIL login (current - recommended)" -ForegroundColor White
Write-Host "2. Change to USERNAME login" -ForegroundColor White
Write-Host "3. Test registration issue" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1, 2, or 3)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "✅ Keeping EMAIL login (current setup)" -ForegroundColor Green
        Write-Host "   - Login uses email address" -ForegroundColor White
        Write-Host "   - Registration collects username + email" -ForegroundColor White
        Write-Host "   - This is the standard modern approach" -ForegroundColor White
        Write-Host ""
        Write-Host "Test credentials:" -ForegroundColor Yellow
        Write-Host "   Email: test@example.com" -ForegroundColor White
        Write-Host "   Password: testpassword" -ForegroundColor White
    }
    "2" {
        Write-Host ""
        Write-Host "🔄 Changing to USERNAME login..." -ForegroundColor Yellow
        Write-Host "   This will require updating both frontend and backend" -ForegroundColor White
        Write-Host "   Do you want to proceed? (y/n)" -ForegroundColor Yellow
        
        $confirm = Read-Host
        if ($confirm -eq "y" -or $confirm -eq "Y") {
            Write-Host "   Updating to username login..." -ForegroundColor Cyan
            # This would require code changes
            Write-Host "   ⚠️  This requires code changes and redeployment" -ForegroundColor Red
        } else {
            Write-Host "   Keeping email login" -ForegroundColor Green
        }
    }
    "3" {
        Write-Host ""
        Write-Host "🔍 Testing Registration Issue..." -ForegroundColor Yellow
        
        Write-Host "Testing backend registration API..." -ForegroundColor Cyan
        try {
            $registerData = @{
                username = "testuser3"
                email = "testuser3@example.com"
                password = "testpassword"
                full_name = "Test User 3"
            } | ConvertTo-Json

            $response = Invoke-RestMethod -Uri "https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io/api/auth/register" -Method POST -ContentType "application/json" -Body $registerData -TimeoutSec 10
            Write-Host "   ✅ Backend registration working: $($response.message)" -ForegroundColor Green
            Write-Host "   ✅ User created: $($response.user.username) ($($response.user.email))" -ForegroundColor Green
        } catch {
            Write-Host "   ❌ Backend registration failed: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        Write-Host ""
        Write-Host "If backend works but frontend doesn't:" -ForegroundColor Yellow
        Write-Host "   - Check browser console for errors" -ForegroundColor White
        Write-Host "   - Try clearing browser cache" -ForegroundColor White
        Write-Host "   - Check if frontend is using latest code" -ForegroundColor White
    }
    default {
        Write-Host "Invalid choice. Please run the script again." -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Current Application Status ===" -ForegroundColor Green
Write-Host "Frontend: https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io" -ForegroundColor White
Write-Host "Backend: https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io" -ForegroundColor White
Write-Host ""
Write-Host "Login URL: https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io/login" -ForegroundColor Yellow
Write-Host "Register URL: https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io/register" -ForegroundColor Yellow 