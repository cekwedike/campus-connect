# Setup Azure Service Principal for GitHub Actions
Write-Host "🔧 Setting up Azure Service Principal for GitHub Actions..." -ForegroundColor Green

# Check if Azure CLI is installed
try {
    az version | Out-Null
    Write-Host "✅ Azure CLI is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI is not installed. Please install it first: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor Red
    exit 1
}

# Login to Azure
Write-Host "`n🔐 Logging into Azure..." -ForegroundColor Yellow
az login

# Get subscription ID
Write-Host "`n📋 Getting subscription information..." -ForegroundColor Yellow
$subscription = az account show --query "{id:id, name:name}" | ConvertFrom-Json
Write-Host "Current subscription: $($subscription.name) ($($subscription.id))" -ForegroundColor Cyan

# Create service principal
Write-Host "`n👤 Creating service principal..." -ForegroundColor Yellow
$spName = "campus-connect-github-actions"
$sp = az ad sp create-for-rbac --name $spName --role contributor --scopes /subscriptions/$($subscription.id) --sdk-auth | ConvertFrom-Json

if ($sp) {
    Write-Host "✅ Service principal created successfully!" -ForegroundColor Green
    
    # Display the credentials (this should be added to GitHub Secrets)
    Write-Host "`n🔑 Service Principal Credentials:" -ForegroundColor Yellow
    Write-Host "Add these to your GitHub repository secrets:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "AZURE_CREDENTIALS:" -ForegroundColor Green
    Write-Host ($sp | ConvertTo-Json -Depth 10) -ForegroundColor White
    Write-Host ""
    Write-Host "AZURE_SUBSCRIPTION_ID: $($subscription.id)" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "📝 Instructions:" -ForegroundColor Yellow
    Write-Host "1. Go to your GitHub repository: https://github.com/cekwedike/campus-connect" -ForegroundColor White
    Write-Host "2. Go to Settings > Secrets and variables > Actions" -ForegroundColor White
    Write-Host "3. Add the following secrets:" -ForegroundColor White
    Write-Host "   - AZURE_CREDENTIALS: (the JSON output above)" -ForegroundColor White
    Write-Host "   - AZURE_SUBSCRIPTION_ID: $($subscription.id)" -ForegroundColor White
    Write-Host ""
    Write-Host "4. Also ensure you have these secrets for ACR:" -ForegroundColor White
    Write-Host "   - ACR_USERNAME: campusconnect2024acr" -ForegroundColor White
    Write-Host "   - ACR_PASSWORD: (your ACR password)" -ForegroundColor White
    Write-Host ""
    Write-Host "✅ Setup complete! Your GitHub Actions should now be able to authenticate with Azure." -ForegroundColor Green
    
} else {
    Write-Host "❌ Failed to create service principal" -ForegroundColor Red
    exit 1
} 