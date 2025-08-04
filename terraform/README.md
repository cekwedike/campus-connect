# Terraform Infrastructure for Campus Connect

This directory contains the Infrastructure as Code (IaC) configuration for the Campus Connect application using Terraform and Azure.

## 🏗️ **Infrastructure Overview**

### **Environments**
- **Production**: Main application environment
- **Staging**: Pre-production testing environment

### **Resources Deployed**

#### **Networking**
- Virtual Network with dedicated subnet for Container Apps
- Network security and routing

#### **Container Infrastructure**
- Azure Container Registry (ACR) for image storage
- Container Apps Environment for orchestration
- Production and Staging Container Apps for both backend and frontend

#### **Database**
- PostgreSQL Server with production and staging databases
- Automated backups and monitoring

#### **Monitoring & Observability**
- Log Analytics Workspace for centralized logging
- Application Insights for application monitoring
- Health checks and alerting

## 🚀 **Quick Start**

### **Prerequisites**
1. Azure CLI installed and authenticated
2. Terraform installed (version 1.5.0+)
3. Azure subscription with appropriate permissions

### **Local Deployment**

1. **Navigate to terraform directory:**
```bash
cd terraform
```

2. **Initialize Terraform:**
```bash
terraform init
```

3. **Create terraform.tfvars file:**
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

4. **Plan the deployment:**
```bash
terraform plan
```

5. **Apply the infrastructure:**
```bash
terraform apply
```

### **Automated Deployment**

The infrastructure is automatically deployed via GitHub Actions when:
- Changes are pushed to `main` branch (production)
- Changes are pushed to `develop` branch (staging)
- Manual trigger via workflow dispatch

## 📋 **Configuration**

### **Variables**

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `location` | Azure region | "West US 2" | No |
| `environment` | Environment name | "production" | No |
| `db_name` | Database name | "campusconnect" | No |
| `db_username` | Database username | "postgres" | No |
| `db_password` | Database password | - | **Yes** |
| `secret_key` | JWT secret key | - | **Yes** |

### **Secrets Required**

Add these secrets to your GitHub repository:

- `AZURE_CREDENTIALS`: Azure service principal credentials
- `DB_PASSWORD`: Strong database password
- `SECRET_KEY`: JWT secret key for authentication

## 🌐 **URLs and Endpoints**

After deployment, the following URLs will be available:

### **Production Environment**
- Backend API: `https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io`
- Frontend App: `https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io`

### **Staging Environment**
- Backend API: `https://campus-connect-backend-staging.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io`
- Frontend App: `https://campus-connect-frontend-staging.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io`

## 🔧 **Infrastructure Components**

### **Container Apps**
- **Backend**: FastAPI application with PostgreSQL connection
- **Frontend**: React application with API integration
- **Scaling**: Auto-scaling based on CPU and memory usage
- **Health Checks**: Automated health monitoring

### **Database**
- **PostgreSQL 11**: Reliable relational database
- **Backup**: 7-day retention with automated backups
- **Security**: SSL enforcement and network isolation

### **Monitoring**
- **Application Insights**: Real-time application monitoring
- **Log Analytics**: Centralized logging and analysis
- **Health Checks**: Automated endpoint monitoring

## 🔒 **Security Features**

- **Network Isolation**: Container Apps in dedicated subnet
- **SSL/TLS**: All endpoints use HTTPS
- **Database Security**: SSL enforcement and strong authentication
- **Secret Management**: Sensitive values stored as secrets

## 📊 **Monitoring and Observability**

### **Application Insights**
- Real-time application performance monitoring
- Error tracking and alerting
- User behavior analytics
- Custom metrics and dashboards

### **Log Analytics**
- Centralized log collection
- Advanced querying capabilities
- Automated alerting
- Compliance reporting

## 🚨 **Troubleshooting**

### **Common Issues**

1. **Container App Not Starting**
   - Check application logs in Azure Portal
   - Verify environment variables are set correctly
   - Ensure database connectivity

2. **Database Connection Issues**
   - Verify firewall rules allow Container Apps access
   - Check database credentials in environment variables
   - Ensure SSL is properly configured

3. **Terraform Apply Failures**
   - Check Azure credentials and permissions
   - Verify resource naming conflicts
   - Review Terraform plan output

### **Useful Commands**

```bash
# Check Container App logs
az containerapp logs show --name campus-connect-backend --resource-group campus-connect-rg

# Check database connectivity
az postgres flexible-server show --name campus-connect-db --resource-group campus-connect-rg

# View Terraform state
terraform show

# Destroy infrastructure (use with caution)
terraform destroy
```

## 🔄 **CI/CD Integration**

The Terraform infrastructure integrates seamlessly with the GitHub Actions CI/CD pipeline:

1. **Infrastructure First**: Terraform runs before application deployment
2. **Environment Variables**: Container Apps receive proper configuration
3. **Health Checks**: Automated verification after deployment
4. **Rollback Capability**: Previous revisions can be restored

## 📈 **Scaling and Performance**

### **Auto-scaling Rules**
- **CPU**: Scale up when CPU > 70%, scale down when < 30%
- **Memory**: Scale up when memory > 80%, scale down when < 50%
- **Min Replicas**: 1 for staging, 2 for production
- **Max Replicas**: 10 for both environments

### **Performance Optimization**
- **Container Registry**: Premium tier for faster image pulls
- **Database**: Optimized SKU for production workloads
- **Networking**: Low-latency connections between services

## 🎯 **Best Practices**

1. **Version Control**: All infrastructure changes are version controlled
2. **State Management**: Terraform state stored securely
3. **Security**: Least privilege access and network isolation
4. **Monitoring**: Comprehensive observability and alerting
5. **Backup**: Automated database backups and disaster recovery
6. **Documentation**: Clear documentation and runbooks

## 📞 **Support**

For infrastructure issues:
1. Check the GitHub Actions logs
2. Review Azure Portal monitoring
3. Consult this documentation
4. Contact the DevOps team

---

**Last Updated**: $(date)
**Terraform Version**: 1.5.0
**Azure Provider**: ~>3.0 