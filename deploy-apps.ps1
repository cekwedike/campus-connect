# Deploy CampusConnect to Azure Container Apps
Write-Host "🚀 Deploying CampusConnect to Azure Container Apps" -ForegroundColor Green

# Variables
$RESOURCE_GROUP = "campus-connect-rg"
$LOCATION = "westus2"
$ACR_NAME = "campusconnect2024acr"
$ACR_LOGIN_SERVER = "$ACR_NAME.azurecr.io"

# Get ACR credentials
Write-Host "Getting ACR credentials..." -ForegroundColor Yellow
$ACR_PASSWORD = az acr credential show --name $ACR_NAME --query "passwords[0].value" --output tsv

# Create Container Apps Environment
Write-Host "Creating Container Apps Environment..." -ForegroundColor Yellow
az containerapp env create `
    --name "campus-connect-env" `
    --resource-group $RESOURCE_GROUP `
    --location $LOCATION

# Deploy Backend
Write-Host "Deploying Backend..." -ForegroundColor Yellow
az containerapp create `
    --name "campus-connect-backend" `
    --resource-group $RESOURCE_GROUP `
    --environment "campus-connect-env" `
    --image "$ACR_LOGIN_SERVER/campus-connect-backend:latest" `
    --registry-server $ACR_LOGIN_SERVER `
    --registry-username $ACR_NAME `
    --registry-password $ACR_PASSWORD `
    --target-port 8000 `
    --ingress external `
    --env-vars "DATABASE_URL=postgresql://postgres:Enechi_1206@campus-connect-db.postgres.database.azure.com:5432/campusconnect" "SECRET_KEY=1234567890ekwedike" "ENVIRONMENT=production"

# Get Backend URL
$BACKEND_URL = az containerapp show --name "campus-connect-backend" --resource-group $RESOURCE_GROUP --query "properties.configuration.ingress.fqdn" --output tsv

# Deploy Frontend
Write-Host "Deploying Frontend..." -ForegroundColor Yellow
az containerapp create `
    --name "campus-connect-frontend" `
    --resource-group $RESOURCE_GROUP `
    --environment "campus-connect-env" `
    --image "$ACR_LOGIN_SERVER/campus-connect-frontend:latest" `
    --registry-server $ACR_LOGIN_SERVER `
    --registry-username $ACR_NAME `
    --registry-password $ACR_PASSWORD `
    --target-port 80 `
    --ingress external `
    --env-vars "REACT_APP_API_URL=https://$BACKEND_URL" "ENVIRONMENT=production"

# Get Frontend URL
$FRONTEND_URL = az containerapp show --name "campus-connect-frontend" --resource-group $RESOURCE_GROUP --query "properties.configuration.ingress.fqdn" --output tsv

Write-Host "`n✅ Deployment Complete!" -ForegroundColor Green
Write-Host "Frontend URL: https://$FRONTEND_URL" -ForegroundColor Cyan
Write-Host "Backend URL: https://$BACKEND_URL" -ForegroundColor Cyan
Write-Host "`n🎉 Your application is now live!" -ForegroundColor Green 