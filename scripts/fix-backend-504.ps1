# Fix Backend 504 Gateway Timeout Issue
Write-Host "🔧 Fixing Backend 504 Gateway Timeout Issue..." -ForegroundColor Green

# Azure Container Registry details
$ACR_NAME = "campusconnectacr"
$RESOURCE_GROUP = "campus-connect-rg"
$BACKEND_APP_NAME = "campus-connect-backend"

Write-Host "`n📋 Step 1: Building new backend image..." -ForegroundColor Yellow
try {
    # Build the new backend image
    docker build -t "${ACR_NAME}.azurecr.io/backend:latest" ./backend
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Backend image built successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Backend image build failed!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Error building backend image: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n📋 Step 2: Pushing image to Azure Container Registry..." -ForegroundColor Yellow
try {
    # Login to ACR
    az acr login --name $ACR_NAME
    
    # Push the image
    docker push $ACR_NAME.azurecr.io/backend:latest
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Backend image pushed successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Backend image push failed!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Error pushing backend image: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n📋 Step 3: Redeploying backend to Azure Container Apps..." -ForegroundColor Yellow
try {
    # Update the backend container app
    az containerapp update `
        --name $BACKEND_APP_NAME `
        --resource-group $RESOURCE_GROUP `
        --image $ACR_NAME.azurecr.io/backend:latest `
        --set-env-vars "ENVIRONMENT=production" `
        --set-env-vars "CORS_ORIGINS=https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Backend redeployed successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Backend redeployment failed!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Error redeploying backend: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n📋 Step 4: Waiting for deployment to stabilize..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host "`n📋 Step 5: Testing backend health..." -ForegroundColor Yellow
try {
    $maxRetries = 10
    $retryCount = 0
    
    while ($retryCount -lt $maxRetries) {
        Write-Host "Attempt $($retryCount + 1) of $maxRetries..." -ForegroundColor Cyan
        
        try {
            $response = Invoke-RestMethod -Uri "https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io/health" -Method GET -TimeoutSec 10
            Write-Host "✅ Backend health check passed: $($response | ConvertTo-Json)" -ForegroundColor Green
            break
        } catch {
            Write-Host "⚠️ Health check attempt $($retryCount + 1) failed: $($_.Exception.Message)" -ForegroundColor Yellow
            $retryCount++
            if ($retryCount -lt $maxRetries) {
                Write-Host "Waiting 10 seconds before retry..." -ForegroundColor Cyan
                Start-Sleep -Seconds 10
            }
        }
    }
    
    if ($retryCount -eq $maxRetries) {
        Write-Host "❌ Backend health check failed after $maxRetries attempts!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Error testing backend health: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n📋 Step 6: Testing root endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io/" -Method GET -TimeoutSec 10
    Write-Host "✅ Root endpoint test passed: $($response | ConvertTo-Json)" -ForegroundColor Green
} catch {
    Write-Host "❌ Root endpoint test failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n🎉 Backend 504 Gateway Timeout issue has been fixed!" -ForegroundColor Green
Write-Host "✅ Backend is now running and responding to requests" -ForegroundColor Green
Write-Host "🌐 Backend URL: https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io/" -ForegroundColor Cyan 