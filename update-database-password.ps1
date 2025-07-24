# Update Database Password Securely
Write-Host "🔐 Updating Database Password Securely" -ForegroundColor Green

# Prompt for new password (this will be hidden when typing)
$NewPassword = Read-Host "Enter new strong password for database" -AsSecureString
$NewPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($NewPassword))

if ([string]::IsNullOrEmpty($NewPasswordPlain)) {
    Write-Host "❌ Password cannot be empty!" -ForegroundColor Red
    exit 1
}

if ($NewPasswordPlain.Length -lt 8) {
    Write-Host "❌ Password must be at least 8 characters long!" -ForegroundColor Red
    exit 1
}

Write-Host "Updating PostgreSQL database password..." -ForegroundColor Yellow

# Update the PostgreSQL server password
az postgres flexible-server update `
    --resource-group campus-connect-rg `
    --name campus-connect-postgres `
    --admin-password $NewPasswordPlain

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Database password updated successfully!" -ForegroundColor Green
    
    # Get the database FQDN
    $DB_FQDN = az postgres flexible-server show `
        --resource-group campus-connect-rg `
        --name campus-connect-postgres `
        --query "fullyQualifiedDomainName" `
        --output tsv
    
    # Create new connection string
    $DATABASE_URL = "postgresql://postgres:$NewPasswordPlain@$DB_FQDN:5432/campusconnect"
    
    # Update backend with new connection string
    Write-Host "Updating backend with new database connection..." -ForegroundColor Yellow
    az containerapp update `
        --name campus-connect-backend `
        --resource-group campus-connect-rg `
        --set-env-vars "DATABASE_URL=$DATABASE_URL"
    
    Write-Host "✅ Backend updated with new database connection!" -ForegroundColor Green
    Write-Host "`n🔐 Password updated successfully!" -ForegroundColor Green
    Write-Host "Please save your new password securely!" -ForegroundColor Yellow
    
} else {
    Write-Host "❌ Failed to update database password!" -ForegroundColor Red
    Write-Host "You may need to update it manually in the Azure portal." -ForegroundColor Yellow
}

# Clear the password from memory
$NewPasswordPlain = $null 