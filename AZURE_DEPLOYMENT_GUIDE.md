# 🚀 Azure Deployment Guide for CampusConnect

This guide will walk you through deploying CampusConnect to Azure step by step.

## 📋 Prerequisites

1. **Azure Account**: You need an active Azure subscription
2. **Azure CLI**: Already installed via winget
3. **Terraform**: Already installed
4. **Docker**: Already installed and running

## 🔧 Step-by-Step Deployment

### Step 1: Restart Terminal and Verify Azure CLI

1. **Close and reopen PowerShell** (to refresh PATH)
2. **Navigate to project directory**:
   ```powershell
   cd "C:\Users\cheed\Downloads\campus-connect\campus-connect"
   ```
3. **Verify Azure CLI**:
   ```powershell
   az --version
   ```

### Step 2: Login to Azure

```powershell
az login
```
- This opens a browser window
- Sign in with your Azure account credentials
- Return to PowerShell when complete

### Step 3: Set Your Azure Subscription

```powershell
# List all subscriptions
az account list --output table

# Set your subscription (replace with your subscription ID)
az account set --subscription "your-subscription-id"
```

### Step 4: Configure Terraform Variables

1. **Copy the example file**:
   ```powershell
   cd terraform
   copy terraform.tfvars.example terraform.tfvars
   ```

2. **Edit terraform.tfvars** with your values:
   ```powershell
   notepad terraform.tfvars
   ```
   
   **Important**: Change these values:
   - `db_password`: Use a strong password
   - `secret_key`: Use a strong secret key
   - `location`: Choose your preferred Azure region

### Step 5: Deploy Infrastructure

```powershell
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the changes (this will create all Azure resources)
terraform apply
```

**Note**: This step will:
- Create a Resource Group
- Create a Virtual Network
- Create Azure Container Registry
- Create Azure Database for PostgreSQL
- Create Container Apps Environment
- Create Application Gateway
- This may take 10-15 minutes

### Step 6: Build and Push Docker Images

```powershell
# Go back to project root
cd ..

# Make deployment script executable (if needed)
# chmod +x scripts/deploy.sh  # (Linux/Mac only)

# Set environment variables
$ACR_NAME = (terraform -chdir=terraform output -raw acr_login_server).Split('.')[0]
$env:ACR_NAME = $ACR_NAME

# Run deployment script
.\scripts\deploy.sh
```

### Step 7: Update Container Apps

```powershell
# Get resource group name
$RG_NAME = terraform -chdir=terraform output -raw resource_group_name
$ACR_SERVER = terraform -chdir=terraform output -raw acr_login_server

# Update backend container app
az containerapp update --name backend-app --resource-group $RG_NAME --image "$ACR_SERVER/campus-connect-backend:latest"

# Update frontend container app
az containerapp update --name frontend-app --resource-group $RG_NAME --image "$ACR_SERVER/campus-connect-frontend:latest"
```

### Step 8: Access Your Application

```powershell
# Get the Application Gateway URL
terraform -chdir=terraform output app_gateway_url

# Your application will be available at:
# Frontend: http://<app-gateway-url>
# Backend: http://<app-gateway-url>/api
```

## 🧪 Testing Your Deployment

### 1. Test Frontend
- Open the frontend URL in your browser
- You should see the CampusConnect login page

### 2. Test Backend API
- Open the backend URL + `/docs` in your browser
- You should see the FastAPI documentation

### 3. Create a Test User
```powershell
# Access the backend container app logs
az containerapp logs show --name backend-app --resource-group $RG_NAME --follow
```

## 🔍 Troubleshooting

### Common Issues:

1. **Azure CLI not found**:
   - Restart PowerShell after installation
   - Check if Azure CLI is in PATH

2. **Terraform authentication error**:
   ```powershell
   az account get-access-token
   ```

3. **Container Apps not starting**:
   ```powershell
   az containerapp logs show --name backend-app --resource-group $RG_NAME
   az containerapp logs show --name frontend-app --resource-group $RG_NAME
   ```

4. **Database connection issues**:
   - Check if the database password is correct
   - Verify the database server is running

### Useful Commands:

```powershell
# List all resources in your resource group
az resource list --resource-group $RG_NAME --output table

# Check Container Apps status
az containerapp list --resource-group $RG_NAME --output table

# Check ACR repositories
az acr repository list --name $ACR_NAME

# Get database connection string
az postgres flexible-server show --name <server-name> --resource-group $RG_NAME
```

## 🧹 Cleanup (When Done)

To avoid charges, you can delete all resources:

```powershell
cd terraform
terraform destroy
```

## 📞 Support

If you encounter any issues:
1. Check the troubleshooting section above
2. Review Azure portal for resource status
3. Check Container App logs for application errors
4. Verify all environment variables are set correctly

---

**🎉 Congratulations! Your CampusConnect application is now running on Azure!** 