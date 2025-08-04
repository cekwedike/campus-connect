# Phase 3 Testing Guide: How to Test Your Implementation

## 🧪 **Comprehensive Testing Plan**

This guide provides step-by-step instructions to test all components of your Phase 3 Continuous Deployment implementation.

## 📋 **Pre-Testing Checklist**

### **1. GitHub Secrets Setup**
Before testing, ensure these secrets are configured in your GitHub repository:

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Add these secrets:
   - `AZURE_CREDENTIALS`: Azure service principal credentials
   - `ACR_USERNAME`: Azure Container Registry username
   - `ACR_PASSWORD`: Azure Container Registry password

### **2. Azure CLI Login**
```bash
az login
az account show
```

### **3. Verify Azure Resources**
```bash
# Check resource group
az group show --name campus-connect-rg

# Check container apps
az containerapp list --resource-group campus-connect-rg

# Check container registry
az acr show --name campusconnect2024acr --resource-group campus-connect-rg
```

## 🚀 **Step-by-Step Testing**

### **Step 1: Test Live Environments**

#### **Production Environment**
```bash
# Test production frontend
curl -I https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io

# Test production backend
curl -I https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io
```

#### **Expected Results**:
- ✅ Status 200: Environment is healthy
- ❌ Connection failed: Environment needs deployment

### **Step 2: Test Docker Image Builds**

#### **Backend Image**
```bash
cd backend
docker build -t test-backend .
```

#### **Frontend Image**
```bash
cd frontend
docker build -t test-frontend .
```

#### **Expected Results**:
- ✅ Build successful: Images are properly configured
- ❌ Build failed: Check Dockerfile syntax and dependencies

### **Step 3: Test Azure Container Registry**

```bash
# Login to ACR
az acr login --name campusconnect2024acr

# List repositories
az acr repository list --name campusconnect2024acr
```

#### **Expected Results**:
- ✅ Login successful: ACR is accessible
- ❌ Login failed: Check ACR permissions

### **Step 4: Test Pipeline Files**

Verify all required files exist:
```bash
# Check pipeline file
ls .github/workflows/cd-pipeline.yml

# Check documentation
ls CHANGELOG.md README.md

# Check monitoring files
ls monitoring/dashboard.json monitoring/alerts.json

# Check scripts
ls scripts/setup-monitoring.ps1
```

### **Step 5: Test Pipeline Execution**

#### **Trigger a Test Pipeline**
```bash
# Make a small change
echo "# Test comment" >> README.md

# Commit and push
git add .
git commit -m "test: trigger pipeline test"
git push origin main
```

#### **Monitor Pipeline**
1. Go to GitHub repository
2. Navigate to **Actions** tab
3. Watch the pipeline execution
4. Check each stage:
   - ✅ Test stage
   - ✅ Security stage
   - ✅ Build stage
   - ✅ Deploy stage
   - ✅ Monitoring stage

### **Step 6: Test Security Scanning**

#### **Check Security Tab**
1. Go to GitHub repository
2. Navigate to **Security** tab
3. Look for:
   - ✅ Trivy scan results
   - ✅ Bandit scan results
   - ✅ Safety scan results

### **Step 7: Test Monitoring Setup**

#### **Run Monitoring Setup**
```bash
# Execute monitoring setup
.\scripts\setup-monitoring.ps1
```

#### **Check Azure Application Insights**
1. Go to Azure Portal
2. Navigate to Application Insights
3. Look for:
   - ✅ Application Insights resource
   - ✅ Log Analytics workspace
   - ✅ Monitoring dashboard

### **Step 8: Test Environment Protection**

#### **Test Staging Deployment**
```bash
# Create feature branch
git checkout -b feature/test-deployment

# Make change
echo "// Test change" >> frontend/src/App.js

# Commit and push
git add .
git commit -m "feat: test deployment"
git push origin feature/test-deployment

# Create PR to develop branch
# Check pipeline execution
```

#### **Test Production Deployment**
```bash
# Merge develop to main
git checkout main
git merge develop
git push origin main

# Check production pipeline execution
```

## 🔧 **Troubleshooting Common Issues**

### **Issue 1: Live Environments Not Accessible**

#### **Symptoms**:
- Connection failed to production/staging URLs
- 404 or 500 errors

#### **Solutions**:
1. **Check Container Apps Status**:
   ```bash
   az containerapp list --resource-group campus-connect-rg --query "[].{name:name,status:properties.runningStatus}"
   ```

2. **Check Container App Logs**:
   ```bash
   az containerapp logs show --name campus-connect-frontend --resource-group campus-connect-rg
   az containerapp logs show --name campus-connect-backend --resource-group campus-connect-rg
   ```

3. **Redeploy Applications**:
   ```bash
   # Redeploy frontend
   az containerapp update --name campus-connect-frontend --resource-group campus-connect-rg --image campusconnect2024acr.azurecr.io/campusconnect-frontend:latest
   
   # Redeploy backend
   az containerapp update --name campus-connect-backend --resource-group campus-connect-rg --image campusconnect2024acr.azurecr.io/campusconnect-backend:latest
   ```

### **Issue 2: Docker Build Failures**

#### **Symptoms**:
- Docker build fails with errors
- Missing dependencies

#### **Solutions**:
1. **Check Dockerfile Syntax**:
   ```bash
   # Test backend Dockerfile
   docker build -t test-backend ./backend --no-cache
   
   # Test frontend Dockerfile
   docker build -t test-frontend ./frontend --no-cache
   ```

2. **Check Dependencies**:
   ```bash
   # Backend dependencies
   cat backend/requirements.txt
   
   # Frontend dependencies
   cat frontend/package.json
   ```

### **Issue 3: Pipeline Failures**

#### **Symptoms**:
- GitHub Actions pipeline fails
- Missing secrets or permissions

#### **Solutions**:
1. **Check GitHub Secrets**:
   - Verify all required secrets are set
   - Check secret names match pipeline configuration

2. **Check Azure Permissions**:
   ```bash
   # Verify Azure CLI permissions
   az role assignment list --assignee $(az account show --query user.name -o tsv)
   ```

3. **Check Pipeline Logs**:
   - Go to GitHub Actions
   - Click on failed workflow
   - Check detailed error messages

### **Issue 4: Security Scanning Failures**

#### **Symptoms**:
- Security scans fail in pipeline
- No security results in GitHub

#### **Solutions**:
1. **Check Security Tools**:
   ```bash
   # Test safety locally
   pip install safety
   safety check
   
   # Test bandit locally
   pip install bandit
   bandit -r backend/app/
   ```

2. **Check Trivy Installation**:
   ```bash
   # Install Trivy locally
   # Follow Trivy installation guide for your OS
   trivy image --help
   ```

## 📊 **Testing Results Template**

### **Test Results Checklist**

| Component | Status | Notes |
|-----------|--------|-------|
| GitHub Secrets | ⬜ | Configure AZURE_CREDENTIALS, ACR_USERNAME, ACR_PASSWORD |
| Azure Resources | ⬜ | Verify resource group, container apps, ACR |
| Live Environments | ⬜ | Test production and staging URLs |
| Docker Builds | ⬜ | Test backend and frontend image builds |
| Pipeline Execution | ⬜ | Trigger and monitor pipeline |
| Security Scanning | ⬜ | Check security tab and scan results |
| Monitoring Setup | ⬜ | Run monitoring setup script |
| Environment Protection | ⬜ | Test staging and production deployments |

### **Success Criteria**

- ✅ All live environments accessible (200 status)
- ✅ Docker images build successfully
- ✅ Pipeline executes without errors
- ✅ Security scans complete successfully
- ✅ Monitoring dashboard accessible
- ✅ Environment protection working

## 🎯 **Video Demonstration Testing**

### **Pre-Demonstration Checklist**

1. **Verify Production Environment**:
   - Navigate to production URL
   - Confirm application is functional
   - Test login functionality

2. **Prepare Code Changes**:
   - Identify visible change to make
   - Prepare conventional commit message
   - Test change locally

3. **Check Pipeline Status**:
   - Ensure no running pipelines
   - Verify GitHub Actions are enabled
   - Check branch protection rules

4. **Prepare Monitoring Dashboard**:
   - Open Azure Application Insights
   - Verify monitoring is active
   - Check alert configurations

### **Demonstration Flow**

1. **Stage 1 (2 min)**: Show production application
2. **Stage 2 (2 min)**: Make code change and commit
3. **Stage 3 (3 min)**: Create PR and show pipeline
4. **Stage 4 (2 min)**: Merge to main and show monitoring
5. **Stage 5 (1 min)**: Verify deployment and CHANGELOG

## 🎉 **Final Verification**

### **Complete System Test**

Run this comprehensive test to verify everything works:

```bash
# 1. Test all environments
curl -I https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io
curl -I https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io

# 2. Test Docker builds
docker build -t test-backend ./backend
docker build -t test-frontend ./frontend

# 3. Test pipeline trigger
git add .
git commit -m "test: final verification"
git push origin main

# 4. Check pipeline execution
# Go to GitHub Actions and monitor the pipeline
```

### **Success Indicators**

- ✅ All URLs return 200 status
- ✅ Docker builds complete successfully
- ✅ Pipeline executes all stages
- ✅ Security scans pass
- ✅ Deployment completes
- ✅ Monitoring shows activity

**Your Phase 3 implementation is ready for assessment when all tests pass!** 🚀 