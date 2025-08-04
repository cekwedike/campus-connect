# CampusConnect - Student Collaboration Platform

A modern, full-stack web application for university student collaboration, built with React, FastAPI, and PostgreSQL.

## 🚀 Features

- **User Authentication**: Secure registration and login system
- **Project Management**: Create and manage collaborative projects
- **Task Management**: Organize tasks within projects
- **File Sharing**: Upload and share files within projects
- **Real-time Search**: Global search across projects, tasks, and users
- **Responsive Design**: Modern UI that works on all devices
- **PWA Support**: Progressive Web App capabilities

## 🏗️ Architecture

- **Frontend**: React 18 with TailwindCSS
- **Backend**: FastAPI with Python 3.11
- **Database**: PostgreSQL 13
- **Authentication**: JWT tokens
- **Containerization**: Docker & Docker Compose
- **Cloud**: Azure Container Apps, Azure Database for PostgreSQL, ACR, Application Gateway

## 📋 Prerequisites

- Docker & Docker Compose
- Node.js 16+ (for local development)
- Python 3.11+ (for local development)
- Azure CLI (for cloud deployment)
- Terraform (for infrastructure)

## 🐳 Quick Start with Docker

### 1. Clone the Repository
```bash
git clone <repository-url>
cd campus-connect
```

### 2. Set Up Environment Variables
```bash
cp env.example .env
# Edit .env with your configuration
```

### 3. Start the Application
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### 4. Access the Application
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs

### 5. Create Initial User
```bash
# Access backend container
docker-compose exec backend python

# Create a test user
from app.core.database import SessionLocal
from app.models.user import User
from app.core.security import get_password_hash

db = SessionLocal()
user = User(
    username='admin',
    email='admin@example.com',
    full_name='Administrator',
    hashed_password=get_password_hash('password123')
)
db.add(user)
db.commit()
print('User created successfully')
```

## ☁️ Azure Cloud Deployment

### Live Environments

#### Production Environment
- **Frontend**: https://campus-connect-frontend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io
- **Backend**: https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io
- **API Documentation**: https://campus-connect-backend.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io/docs

#### Staging Environment
- **Frontend**: https://campus-connect-frontend-staging.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io
- **Backend**: https://campus-connect-backend-staging.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io
- **API Documentation**: https://campus-connect-backend-staging.wonderfulbeach-2ba06ab4.westus2.azurecontainerapps.io/docs

### Infrastructure as Code (Terraform)

The infrastructure is fully automated using Terraform:

1. **Complete Infrastructure**: Virtual networks, Container Apps, databases, monitoring
2. **Multi-Environment**: Separate staging and production environments
3. **Automated Deployment**: Infrastructure deploys via GitHub Actions
4. **Security**: Network isolation, SSL/TLS, secret management
5. **Monitoring**: Application Insights, Log Analytics, health checks
6. **Scalability**: Auto-scaling rules and performance optimization

### Continuous Deployment

The application uses a fully automated CI/CD pipeline that:

1. **Infrastructure First**: Terraform deploys infrastructure before applications
2. **Automated Testing**: Runs comprehensive tests on every commit (backend + frontend)
3. **Security Scanning**: Performs dependency and container vulnerability scans
4. **Conventional Commits**: Enforces standardized commit message format
5. **Staging Deployment**: Automatically deploys to staging on `develop` branch
6. **Production Deployment**: Deploys to production on `main` branch with manual approval
7. **Semantic Versioning**: Automatic version bumping and tagging
8. **Monitoring**: Provides real-time health checks and logging

### Manual Deployment (Legacy)

#### Prerequisites
1. Azure Account with appropriate permissions
2. Azure CLI installed and configured
3. Terraform installed
4. Docker installed

#### 1. Configure Azure
```bash
az login
az account set --subscription <your-subscription-id>
```

#### 2. Set Up Terraform Variables
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

#### 3. Deploy Infrastructure
```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply changes
terraform apply
```

#### 4. Build and Push Docker Images
```bash
# Make deployment script executable
chmod +x scripts/deploy.sh

# Set environment variables
export ACR_NAME=$(terraform output -raw acr_login_server | cut -d'.' -f1)
export AZURE_REGION=West US 2

# Deploy images
./scripts/deploy.sh
```

#### 5. Update Container Apps
```bash
# Get Container App names
az containerapp list --resource-group $(terraform output -raw resource_group_name) --query "[].name" -o tsv

# Update Container Apps with new images
az containerapp update --name backend-app --resource-group $(terraform output -raw resource_group_name) --image $(terraform output -raw acr_login_server)/campus-connect-backend:latest
az containerapp update --name frontend-app --resource-group $(terraform output -raw resource_group_name) --image $(terraform output -raw acr_login_server)/campus-connect-frontend:latest
```

## 🛠️ Development Setup

### Git Configuration
```bash
# Configure commit message template
git config commit.template .gitmessage

# Verify configuration
git config --list | grep commit.template
```

### Frontend Development
```bash
cd frontend
npm install
npm start
```

### Backend Development
```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### Database Setup
```bash
# Create database tables
cd backend
python -c "from app.core.database import engine; from app.models import *; from app.core.database import Base; Base.metadata.create_all(bind=engine)"
```

## 🧪 Testing

### Run All Tests
```bash
docker-compose exec backend python -m pytest tests/ -v
```

### Run Specific Tests
```bash
# Auth tests
docker-compose exec backend python -m pytest tests/test_auth.py -v

# API tests
docker-compose exec backend python -m pytest tests/test_main.py -v
```

## 📁 Project Structure

```
campus-connect/
├── backend/                 # FastAPI backend
│   ├── app/
│   │   ├── core/           # Core configuration
│   │   └── main.py         # Main application
│   ├── tests/              # Backend tests
│   ├── Dockerfile          # Backend container
│   └── requirements.txt    # Python dependencies
├── frontend/               # React frontend
│   ├── src/
│   │   ├── components/     # React components
│   │   ├── contexts/       # React contexts
│   │   ├── pages/          # Page components
│   │   └── services/       # API services
│   ├── public/             # Static files
│   ├── Dockerfile          # Frontend container
│   └── package.json        # Node dependencies
├── terraform/              # Infrastructure as Code
│   ├── main.tf             # Main configuration
│   └── variables.tf        # Variable definitions
├── scripts/                # Deployment and utility scripts
├── monitoring/             # Monitoring configuration
├── .github/workflows/      # CI/CD pipelines
├── docker-compose.yml      # Local development
├── docker-compose.prod.yml # Production deployment
├── CHANGELOG.md           # Version history
├── README.md              # This file
└── SECURITY.md            # Security documentation
```

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `POSTGRES_DB` | Database name | `campusconnect` |
| `POSTGRES_USER` | Database user | `postgres` |
| `POSTGRES_PASSWORD` | Database password | `postgres` |
| `SECRET_KEY` | JWT secret key | `your-secret-key-here` |
| `REACT_APP_API_URL` | Backend API URL | `http://localhost:8000` |

### Production Configuration

For production deployment, ensure you:
1. Use strong, unique passwords
2. Set up SSL/TLS certificates
3. Configure proper CORS origins
4. Use managed database services
5. Set up monitoring and logging

## 🚀 API Endpoints

### Authentication
- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/token` - OAuth2 token

### Users
- `GET /api/v1/users` - List users
- `GET /api/v1/users/{id}` - Get user details
- `PUT /api/v1/users/{id}` - Update user

### Projects
- `GET /api/v1/projects` - List projects
- `POST /api/v1/projects` - Create project
- `GET /api/v1/projects/{id}` - Get project details
- `PUT /api/v1/projects/{id}` - Update project
- `DELETE /api/v1/projects/{id}` - Delete project

### Tasks
- `GET /api/v1/tasks` - List tasks
- `POST /api/v1/tasks` - Create task
- `GET /api/v1/tasks/{id}` - Get task details
- `PUT /api/v1/tasks/{id}` - Update task
- `DELETE /api/v1/tasks/{id}` - Delete task

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the API documentation at `/docs`
- Review the test files for usage examples

## 🔄 CI/CD

The project includes Azure DevOps pipelines for:
- Automated testing
- Docker image building
- Security scanning
- Deployment to staging/production

---

**Built with ❤️ for student collaboration**
