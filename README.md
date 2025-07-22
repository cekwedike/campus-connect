# CampusConnect: Simplifying Student Collaboration

## Project Overview

CampusConnect is a centralized web platform for university students to find teammates, organize group projects, and track collaboration progress. It helps students avoid scattered communication by providing a clean, project-focused interface with tools for task assignment, deadlines, and document sharing.

## Features

### ✅ Implemented Features
- **User Authentication**: JWT-based authentication with secure password hashing
- **User Registration & Login**: Complete user management system
- **Project Management**: Create, view, update, and delete projects
- **Task Management**: Create tasks with status tracking (TODO, IN_PROGRESS, REVIEW, DONE)
- **Project Membership**: Add team members with role-based access (Owner, Admin, Member, Viewer)
- **Dashboard**: Overview of projects, tasks, and statistics
- **Responsive UI**: Modern, mobile-friendly interface built with React and Tailwind CSS
- **API Documentation**: Auto-generated Swagger/OpenAPI documentation
- **Database Migrations**: Alembic-based migration system
- **Docker Support**: Complete containerization for easy deployment

### 🚧 Planned Features
- **File Sharing**: Share files and documents in project-specific threads
- **Real-time Collaboration**: WebSocket-based real-time updates
- **Comments & Discussions**: Thread-based discussions on tasks and projects
- **Notifications**: Email and in-app notifications
- **Advanced Search**: Search across projects, tasks, and team members
- **Calendar Integration**: Sync with external calendar applications

## Tech Stack

- **Backend**: Python (FastAPI) + PostgreSQL
- **Frontend**: React.js + TailwindCSS
- **DevOps**: Docker, GitHub Actions, AWS EC2
- **Database**: PostgreSQL

## Project Structure

```
campus-connect/
├── backend/                 # FastAPI backend
│   ├── app/
│   │   ├── api/            # API routes
│   │   ├── core/           # Configuration and utilities
│   │   ├── models/         # Database models
│   │   ├── schemas/        # Pydantic schemas
│   │   └── services/       # Business logic
│   ├── tests/              # Backend tests
│   ├── requirements.txt    # Python dependencies
│   └── Dockerfile          # Backend container
├── frontend/               # React frontend
│   ├── src/
│   │   ├── components/     # React components
│   │   ├── pages/          # Page components
│   │   ├── services/       # API services
│   │   └── utils/          # Utility functions
│   ├── package.json        # Node dependencies
│   └── Dockerfile          # Frontend container
├── docker-compose.yml      # Local development setup
├── .github/                # GitHub Actions workflows
└── README.md               # This file
```

## Local Development Setup

### Prerequisites

- Python 3.9+
- Node.js 16+
- Docker and Docker Compose
- PostgreSQL (or use Docker)

### Quick Start with Docker (Recommended)

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/campus-connect.git
   cd campus-connect
   ```

2. Start all services:
   ```bash
   docker-compose up -d
   ```

3. Access the application:
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8000
   - API Documentation: http://localhost:8000/docs

4. Create your first account:
   - Go to http://localhost:3000/register
   - Create a new account
   - Start using the application!

### Manual Setup

#### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Create a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Set up environment variables:
   ```bash
   cp env.example .env
   # Edit .env with your database credentials
   ```

5. Run database migrations:
   ```bash
   alembic upgrade head
   ```

6. Start the development server:
   ```bash
   uvicorn app.main:app --reload
   ```

#### Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Set up environment variables:
   ```bash
   cp env.example .env
   ```

4. Start the development server:
   ```bash
   npm start
   ```

## Testing

### Backend Tests
```bash
cd backend
pytest
```

### Frontend Tests
```bash
cd frontend
npm test
```

## API Documentation

Once the backend is running, visit:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Contributing

1. Create a feature branch from `develop`
2. Make your changes
3. Write/update tests
4. Ensure CI passes
5. Create a pull request

## License

This project is for educational purposes as part of the Advanced DevOps Course.

## Project Board

[Link to GitHub Project Board](https://github.com/cekwedike/campus-connect/projects/1)

## Repository

[GitHub Repository](https://github.com/cekwedike/campus-connect)

## CI/CD Pipeline

This project uses GitHub Actions for continuous integration. The pipeline includes:

- **Linting**: Code quality checks with flake8 and black
- **Testing**: Unit tests with pytest and coverage reporting
- **Security**: Vulnerability scanning with safety and bandit
- **Build**: Docker image building for containerization

The pipeline runs on:
- Every push to `main` and `develop` branches
- Every pull request to `main` and `develop` branches

## Branch Protection

The `main` branch is protected with the following rules:
- Requires pull request reviews before merging
- Requires status checks to pass before merging
- Requires up-to-date branches before merging 