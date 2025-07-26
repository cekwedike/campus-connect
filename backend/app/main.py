from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
import json
from datetime import datetime, timedelta, timezone
import jwt

app = FastAPI(
    title="CampusConnect API",
    description="A simple working backend for university student collaboration",
    version="1.0.0",
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Secret key for JWT
SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-here")
ALGORITHM = "HS256"


# Pydantic models
class UserRegister(BaseModel):
    username: str
    email: str
    password: str
    full_name: str


class UserLogin(BaseModel):
    email: str
    password: str


# In-memory storage (replace with database later)
users_db = {}
projects_db = []
tasks_db = []

# Add a test user for immediate testing
test_user = {
    "id": 1,
    "username": "testuser",
    "email": "test@example.com",
    "password": "testpassword",  # In production, hash this
    "full_name": "Test User",
    "created_at": datetime.now(timezone.utc).isoformat(),
}
users_db["test@example.com"] = test_user

# Add sample projects for dashboard
sample_projects = [
    {
        "id": 1,
        "title": "CampusConnect Development",
        "description": "Building a collaborative platform for university students to work together on projects and share resources.",
        "status": "active",
        "created_at": datetime.now(timezone.utc).isoformat(),
        "owner_id": 1,
        "members": [1]
    },
    {
        "id": 2,
        "title": "Study Group Management",
        "description": "Organizing study groups for different courses and managing study schedules.",
        "status": "active",
        "created_at": datetime.now(timezone.utc).isoformat(),
        "owner_id": 1,
        "members": [1]
    },
    {
        "id": 3,
        "title": "Resource Sharing Hub",
        "description": "Creating a central hub for sharing academic resources, notes, and study materials.",
        "status": "planning",
        "created_at": datetime.now(timezone.utc).isoformat(),
        "owner_id": 1,
        "members": [1]
    }
]
projects_db.extend(sample_projects)

# Add sample tasks for dashboard
sample_tasks = [
    {
        "id": 1,
        "title": "Design User Interface",
        "description": "Create wireframes and mockups for the main dashboard",
        "status": "done",
        "priority": "high",
        "project_id": 1,
        "assigned_to": 1,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "due_date": (datetime.now(timezone.utc) + timedelta(days=7)).isoformat()
    },
    {
        "id": 2,
        "title": "Implement Authentication",
        "description": "Set up user registration and login functionality",
        "status": "done",
        "priority": "high",
        "project_id": 1,
        "assigned_to": 1,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "due_date": (datetime.now(timezone.utc) + timedelta(days=5)).isoformat()
    },
    {
        "id": 3,
        "title": "Create Study Group Features",
        "description": "Develop features for creating and managing study groups",
        "status": "in_progress",
        "priority": "medium",
        "project_id": 2,
        "assigned_to": 1,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "due_date": (datetime.now(timezone.utc) + timedelta(days=10)).isoformat()
    },
    {
        "id": 4,
        "title": "Set up Resource Library",
        "description": "Create a system for uploading and organizing study materials",
        "status": "todo",
        "priority": "medium",
        "project_id": 3,
        "assigned_to": 1,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "due_date": (datetime.now(timezone.utc) + timedelta(days=14)).isoformat()
    },
    {
        "id": 5,
        "title": "Test Application",
        "description": "Perform comprehensive testing of all features",
        "status": "todo",
        "priority": "high",
        "project_id": 1,
        "assigned_to": 1,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "due_date": (datetime.now(timezone.utc) + timedelta(days=3)).isoformat()
    }
]
tasks_db.extend(sample_tasks)


# Helper functions
def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(minutes=30)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def verify_password(plain_password, hashed_password):
    # Simple password verification (in production, use proper hashing)
    return plain_password == hashed_password


# Basic endpoints
@app.get("/")
async def root():
    return {"message": "Welcome to CampusConnect API", "status": "running"}


@app.get("/health")
async def health_check():
    return {"status": "healthy", "message": "Backend is running"}


@app.get("/ping")
async def ping():
    return {"message": "pong"}


# Authentication endpoints
@app.post("/api/auth/register")
async def register(user: UserRegister):
    if user.email in users_db:
        raise HTTPException(status_code=400, detail="Email already registered")

    # Create user (in production, hash the password)
    user_data = {
        "id": len(users_db) + 1,
        "username": user.username,
        "email": user.email,
        "password": user.password,  # In production, hash this
        "full_name": user.full_name,
        "created_at": datetime.now(timezone.utc).isoformat(),
    }

    users_db[user.email] = user_data

    # Create access token
    access_token = create_access_token(data={"sub": user.email})

    return {
        "status": "success",
        "message": "User registered successfully",
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": user_data["id"],
            "username": user_data["username"],
            "email": user_data["email"],
            "full_name": user_data["full_name"],
        },
    }


@app.post("/api/auth/login")
async def login(user: UserLogin):
    if user.email not in users_db:
        raise HTTPException(status_code=401, detail="Invalid email or password")

    stored_user = users_db[user.email]
    if not verify_password(user.password, stored_user["password"]):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    # Create access token
    access_token = create_access_token(data={"sub": user.email})

    return {
        "status": "success",
        "message": "Login successful",
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": stored_user["id"],
            "username": stored_user["username"],
            "email": stored_user["email"],
            "full_name": stored_user["full_name"],
        },
    }


# User endpoints
@app.get("/api/users")
async def get_users():
    return {
        "users": [
            {
                "id": user["id"],
                "username": user["username"],
                "email": user["email"],
                "full_name": user["full_name"],
            }
            for user in users_db.values()
        ]
    }


@app.get("/api/users/me")
async def get_current_user():
    # In production, verify JWT token
    return {"message": "Current user info", "users_count": len(users_db)}


# Project endpoints
@app.get("/api/projects")
async def get_projects():
    return {"projects": projects_db}


@app.post("/api/projects")
async def create_project(project_data: dict):
    project = {
        "id": len(projects_db) + 1,
        "title": project_data.get("title", "Untitled Project"),
        "description": project_data.get("description", ""),
        "created_by": project_data.get("created_by", "Unknown"),
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    projects_db.append(project)
    return {"status": "success", "project": project}


# Task endpoints
@app.get("/api/tasks")
async def get_tasks():
    return {"tasks": tasks_db}


@app.post("/api/tasks")
async def create_task(task_data: dict):
    task = {
        "id": len(tasks_db) + 1,
        "title": task_data.get("title", "Untitled Task"),
        "description": task_data.get("description", ""),
        "project_id": task_data.get("project_id"),
        "assigned_to": task_data.get("assigned_to", "Unassigned"),
        "status": task_data.get("status", "pending"),
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    tasks_db.append(task)
    return {"status": "success", "task": task}


# Environment info
@app.get("/api/info")
async def get_info():
    return {
        "database_url": os.getenv("DATABASE_URL", "not set"),
        "environment": os.getenv("ENVIRONMENT", "development"),
        "cors_origins": os.getenv("BACKEND_CORS_ORIGINS", "not set"),
        "message": "Backend is working!",
        "users_count": len(users_db),
        "projects_count": len(projects_db),
        "tasks_count": len(tasks_db),
    }
