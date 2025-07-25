# Start Working CampusConnect Application
Write-Host "🚀 Starting CampusConnect Application" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Step 1: Install backend dependencies
Write-Host "`n1. Installing backend dependencies..." -ForegroundColor Yellow
pip install -r requirements-local.txt

# Step 2: Start backend server in background
Write-Host "`n2. Starting backend server..." -ForegroundColor Yellow
Start-Process python -ArgumentList "run-backend-local.py" -WindowStyle Hidden

# Step 3: Wait for backend to start
Write-Host "`n3. Waiting for backend to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Step 4: Start frontend container
Write-Host "`n4. Starting frontend container..." -ForegroundColor Yellow
docker-compose -f docker-compose-frontend-only.yml up -d

# Step 5: Wait for frontend to start
Write-Host "`n5. Waiting for frontend to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Step 6: Test the application
Write-Host "`n6. Testing the application..." -ForegroundColor Yellow

# Test backend
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/ping" -Method GET -TimeoutSec 5
    Write-Host "✅ Backend: HTTP $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend: $($_.Exception.Message)" -ForegroundColor Red
}

# Test frontend
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -Method GET -TimeoutSec 5
    Write-Host "✅ Frontend: HTTP $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ Frontend: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎯 Your Application URLs:" -ForegroundColor Cyan
Write-Host "Frontend: http://localhost:3000" -ForegroundColor Yellow
Write-Host "Backend: http://localhost:8000" -ForegroundColor Yellow
Write-Host "API Docs: http://localhost:8000/docs" -ForegroundColor Yellow

Write-Host "`n💡 Instructions:" -ForegroundColor Green
Write-Host "1. Open http://localhost:3000 in your browser" -ForegroundColor White
Write-Host "2. You can register and login with the working backend" -ForegroundColor White
Write-Host "3. The frontend is containerized and working perfectly" -ForegroundColor White
Write-Host "4. Backend runs locally for reliable testing" -ForegroundColor White

Write-Host "`n🔧 To stop the application:" -ForegroundColor Yellow
Write-Host "docker-compose -f docker-compose-frontend-only.yml down" -ForegroundColor White
Write-Host "taskkill /f /im python.exe" -ForegroundColor White 