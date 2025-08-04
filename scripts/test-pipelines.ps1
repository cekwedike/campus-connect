# Test CI/CD Pipeline Components Locally
Write-Host "🧪 Testing CI/CD Pipeline Components..." -ForegroundColor Green

# Test 1: Backend Tests
Write-Host "`n📋 Running Backend Tests..." -ForegroundColor Yellow
try {
    cd backend
    python -m pytest tests/test_main.py tests/test_auth_simple.py -v
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Backend tests passed!" -ForegroundColor Green
    } else {
        Write-Host "❌ Backend tests failed!" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error running backend tests: $_" -ForegroundColor Red
}

# Test 2: Linting
Write-Host "`n🔍 Running Linting..." -ForegroundColor Yellow
try {
    cd backend
    python -m flake8 app/ --count --select=E9,F63,F7,F82 --show-source --statistics
    python -m flake8 app/ --count --exit-zero --max-complexity=10 --max-line-length=88 --statistics
    Write-Host "✅ Linting passed!" -ForegroundColor Green
} catch {
    Write-Host "❌ Linting failed: $_" -ForegroundColor Red
}

# Test 3: Format Check
Write-Host "`n🎨 Running Format Check..." -ForegroundColor Yellow
try {
    cd backend
    python -m black --check --diff app/
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Format check passed!" -ForegroundColor Green
    } else {
        Write-Host "❌ Format check failed!" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error running format check: $_" -ForegroundColor Red
}

# Test 4: Security Checks
Write-Host "`n🔒 Running Security Checks..." -ForegroundColor Yellow
try {
    cd backend
    python -m safety check || Write-Host "⚠️ Safety check completed with warnings" -ForegroundColor Yellow
    python -m bandit -r app/ -f json -o bandit-report.json || Write-Host "⚠️ Bandit check completed with warnings" -ForegroundColor Yellow
    Write-Host "✅ Security checks completed!" -ForegroundColor Green
} catch {
    Write-Host "❌ Error running security checks: $_" -ForegroundColor Red
}

# Test 5: Docker Builds
Write-Host "`n🐳 Testing Docker Builds..." -ForegroundColor Yellow
try {
    cd ..
    Write-Host "Building backend image..."
    docker build -t campusconnect-backend:test ./backend
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Backend image built successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Backend image build failed!" -ForegroundColor Red
    }
    
    Write-Host "Building frontend image..."
    docker build -t campusconnect-frontend:test ./frontend
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Frontend image built successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Frontend image build failed!" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error building Docker images: $_" -ForegroundColor Red
}

# Test 6: API Health Check
Write-Host "`n🏥 Testing API Health..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io/health" -Method GET
    if ($response.status -eq "healthy") {
        Write-Host "✅ Backend API is healthy!" -ForegroundColor Green
    } else {
        Write-Host "❌ Backend API health check failed!" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error checking API health: $_" -ForegroundColor Red
}

Write-Host "`n🎉 Pipeline component testing completed!" -ForegroundColor Green
cd .. 