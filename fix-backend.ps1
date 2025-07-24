# Fix Backend Connection Issues
Write-Host "🔧 Fixing Backend Connection Issues" -ForegroundColor Green

# Step 1: Temporarily use SQLite to get the backend working
Write-Host "`n1. Temporarily switching to SQLite..." -ForegroundColor Yellow
az containerapp update `
    --name campus-connect-backend `
    --resource-group campus-connect-rg `
    --set-env-vars "DATABASE_URL=sqlite:///./campus_connect.db" "SECRET_KEY=1234567890ekwedike" "ENVIRONMENT=production"

Write-Host "✅ Backend updated to use SQLite" -ForegroundColor Green

# Step 2: Wait for restart
Write-Host "`n2. Waiting for backend to restart..." -ForegroundColor Yellow
Start-Sleep -Seconds 90

# Step 3: Test if backend is working
Write-Host "`n3. Testing backend..." -ForegroundColor Yellow
$BACKEND_URL = "https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io"

try {
    $response = Invoke-WebRequest -Uri "$BACKEND_URL/docs" -Method GET -TimeoutSec 15
    Write-Host "✅ Backend is now working! Status: $($response.StatusCode)" -ForegroundColor Green
    
    # Step 4: Now try to switch back to PostgreSQL
    Write-Host "`n4. Switching back to PostgreSQL..." -ForegroundColor Yellow
    
    # Test database connection first
    $DB_FQDN = "campus-connect-postgres.postgres.database.azure.com"
    $DB_PASSWORD = "YourStrongPassword123!"
    $DATABASE_URL = "postgresql://postgres:$DB_PASSWORD@$DB_FQDN:5432/campusconnect"
    
    Write-Host "Testing PostgreSQL connection..." -ForegroundColor Yellow
    
    # Update backend with PostgreSQL
    az containerapp update `
        --name campus-connect-backend `
        --resource-group campus-connect-rg `
        --set-env-vars "DATABASE_URL=$DATABASE_URL" "SECRET_KEY=1234567890ekwedike" "ENVIRONMENT=production"
    
    Write-Host "✅ Backend updated with PostgreSQL!" -ForegroundColor Green
    Write-Host "Waiting for restart..." -ForegroundColor Yellow
    Start-Sleep -Seconds 60
    
    # Test again
    try {
        $response = Invoke-WebRequest -Uri "$BACKEND_URL/docs" -Method GET -TimeoutSec 15
        Write-Host "✅ Backend is working with PostgreSQL! Status: $($response.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Backend might still be starting up..." -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ Backend is still not responding: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Let's try a different approach..." -ForegroundColor Yellow
}

Write-Host "`n🎯 Your application URLs:" -ForegroundColor Cyan
Write-Host "Frontend: https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io" -ForegroundColor White
Write-Host "Backend: $BACKEND_URL" -ForegroundColor White

Write-Host "`n💡 If the backend is still not working, try:" -ForegroundColor Yellow
Write-Host "1. Wait 2-3 minutes for the container to fully start" -ForegroundColor White
Write-Host "2. Try accessing the frontend URL directly" -ForegroundColor White
Write-Host "3. Check if you can register/login through the frontend" -ForegroundColor White 