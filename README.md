# CampusConnect: Simplifying Student Collaboration

## Project Overview

CampusConnect is a centralized web platform for university students to find teammates, organize group projects, and track collaboration progress. It helps students avoid scattered communication by providing a clean, project-focused interface with tools for task assignment, deadlines, and document sharing.

## Features

- **User Authentication**: Sign up using school email and create/join projects
- **Project Management**: Create projects, assign roles, and set tasks
- **Task Tracking**: Monitor progress with task assignment and status updates
- **File Sharing**: Share files and comments in project-specific threads
- **Real-time Collaboration**: Team activity logs and progress tracking

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

### Backend Setup

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
   cp .env.example .env
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

### Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the development server:
   ```bash
   npm start
   ```

### Using Docker Compose (Recommended)

1. Start all services:
   ```bash
   docker-compose up -d
   ```

2. Access the application:
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8000
   - API Documentation: http://localhost:8000/docs

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

[Link to GitHub Project Board](https://github.com/yourusername/campus-connect/projects/1)

## Repository

[GitHub Repository](https://github.com/yourusername/campus-connect) 