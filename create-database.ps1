# Create PostgreSQL Database for Azure for Students Subscription
Write-Host "🗄️ Creating PostgreSQL Database for Azure for Students" -ForegroundColor Green

# Secure password - change this to your own strong password
$DB_PASSWORD = "YourStrongPassword123!"

# Try different regions that work with Azure for Students
$REGIONS = @("Central US", "East US", "South Central US", "West US 2", "North Central US")

foreach ($REGION in $REGIONS) {
    Write-Host "Trying region: $REGION" -ForegroundColor Yellow
    
    # Try to create PostgreSQL Flexible Server
    $result = az postgres flexible-server create `
        --resource-group campus-connect-rg `
        --name campus-connect-db `
        --location $REGION `
        --admin-user postgres `
        --admin-password $DB_PASSWORD `
        --sku-name Standard_B1ms `
        --version 14 `
        --storage-size 32 `
        --public-access all `
        --tier Burstable 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Database created successfully in $REGION!" -ForegroundColor Green
        break
    } else {
        Write-Host "❌ Failed in $REGION, trying next region..." -ForegroundColor Red
        # Delete any partial resources
        az postgres flexible-server delete --resource-group campus-connect-rg --name campus-connect-db --yes 2>$null
    }
}

if ($LASTEXITCODE -eq 0) {
    # Create the database
    Write-Host "Creating database 'campusconnect'..." -ForegroundColor Yellow
    az postgres flexible-server db create `
        --resource-group campus-connect-rg `
        --server-name campus-connect-db `
        --database-name campusconnect
    
    # Get the database FQDN
    $DB_FQDN = az postgres flexible-server show `
        --resource-group campus-connect-rg `
        --name campus-connect-db `
        --query "fullyQualifiedDomainName" `
        --output tsv
    
    Write-Host "Database FQDN: $DB_FQDN" -ForegroundColor Cyan
    
    # Create the connection string
    $DATABASE_URL = "postgresql://postgres:$DB_PASSWORD@$DB_FQDN:5432/campusconnect"
    
    Write-Host "Database URL: $DATABASE_URL" -ForegroundColor Cyan
    
    # Update backend with the new database URL
    Write-Host "Updating backend with new database connection..." -ForegroundColor Yellow
    az containerapp update `
        --name campus-connect-backend `
        --resource-group campus-connect-rg `
        --set-env-vars "DATABASE_URL=$DATABASE_URL" "SECRET_KEY=1234567890ekwedike" "ENVIRONMENT=production"
    
    Write-Host "✅ Backend updated with PostgreSQL database!" -ForegroundColor Green
    
    # Wait for restart
    Write-Host "Waiting for backend to restart..." -ForegroundColor Yellow
    Start-Sleep -Seconds 60
    
    Write-Host "`n🎉 Database deployment completed!" -ForegroundColor Green
    Write-Host "You should now see multiple resources in your Azure portal:" -ForegroundColor Cyan
    Write-Host "- campus-connect-rg (Resource Group)" -ForegroundColor White
    Write-Host "- campus-connect-db (PostgreSQL Database)" -ForegroundColor White
    Write-Host "- campusconnect2024acr (Container Registry)" -ForegroundColor White
    Write-Host "- campus-connect-env (Container Apps Environment)" -ForegroundColor White
    Write-Host "- campus-connect-backend (Backend App)" -ForegroundColor White
    Write-Host "- campus-connect-frontend (Frontend App)" -ForegroundColor White
    
} else {
    Write-Host "❌ Could not create database in any region. Using alternative approach..." -ForegroundColor Red
    
    # Alternative: Create a simple PostgreSQL server (older version)
    Write-Host "Creating PostgreSQL Single Server..." -ForegroundColor Yellow
    
    az postgres server create `
        --resource-group campus-connect-rg `
        --name campus-connect-db `
        --location "Central US" `
        --admin-user postgres `
        --admin-password $DB_PASSWORD `
        --sku-name B_Gen5_1 `
        --version 11 `
        --ssl-enforcement Enabled
    
    if ($LASTEXITCODE -eq 0) {
        # Create database
        az postgres db create `
            --resource-group campus-connect-rg `
            --server-name campus-connect-db `
            --name campusconnect
        
        # Get FQDN
        $DB_FQDN = az postgres server show `
            --resource-group campus-connect-rg `
            --name campus-connect-db `
            --query "fullyQualifiedDomainName" `
            --output tsv
        
        $DATABASE_URL = "postgresql://postgres:$DB_PASSWORD@$DB_FQDN:5432/campusconnect"
        
        # Update backend
        az containerapp update `
            --name campus-connect-backend `
            --resource-group campus-connect-rg `
            --set-env-vars "DATABASE_URL=$DATABASE_URL" "SECRET_KEY=1234567890ekwedike" "ENVIRONMENT=production"
        
        Write-Host "✅ Database created using Single Server!" -ForegroundColor Green
    } else {
        Write-Host "❌ All database creation attempts failed." -ForegroundColor Red
        Write-Host "This might be due to Azure for Students subscription limitations." -ForegroundColor Yellow
        Write-Host "For your assignment, you can document this as a learning experience." -ForegroundColor Cyan
    }
} 