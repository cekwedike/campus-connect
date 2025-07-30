from fastapi import FastAPI, HTTPException, Request
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

# Add sample projects for testing search
sample_projects = [
    {
        "id": 1,
        "title": "CampusConnect Development",
        "description": "Building a collaborative platform for university students to work together on projects and share resources.",
        "status": "active",
        "owner_id": 1,
        "created_at": datetime.now(timezone.utc).isoformat(),
    },
    {
        "id": 2,
        "title": "Study Group Management",
        "description": "Organizing study groups for different courses and managing study schedules.",
        "status": "active",
        "owner_id": 1,
        "created_at": datetime.now(timezone.utc).isoformat(),
    },
    {
        "id": 3,
        "title": "Resource Sharing Hub",
        "description": "Creating a central hub for sharing academic resources, notes, and study materials.",
        "status": "planning",
        "owner_id": 1,
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
]

# Add sample tasks for testing search
sample_tasks = [
    {
        "id": 1,
        "title": "Design User Interface",
        "description": "Create wireframes and mockups for the main dashboard and project pages.",
        "project_id": 1,
        "assigned_to": 1,
        "status": "in_progress",
        "priority": "high",
        "created_at": datetime.now(timezone.utc).isoformat(),
        "due_date": (datetime.now(timezone.utc) + timedelta(days=7)).isoformat(),
    },
    {
        "id": 2,
        "title": "Implement Authentication",
        "description": "Set up user registration, login, and JWT token management.",
        "project_id": 1,
        "assigned_to": 1,
        "status": "done",
        "priority": "high",
        "created_at": datetime.now(timezone.utc).isoformat(),
        "due_date": (datetime.now(timezone.utc) + timedelta(days=3)).isoformat(),
    },
    {
        "id": 3,
        "title": "Create Study Schedule",
        "description": "Develop a scheduling system for organizing study sessions and group meetings.",
        "project_id": 2,
        "assigned_to": 1,
        "status": "todo",
        "priority": "medium",
        "created_at": datetime.now(timezone.utc).isoformat(),
        "due_date": (datetime.now(timezone.utc) + timedelta(days=14)).isoformat(),
    }
]

# Add sample data to databases
projects_db.extend(sample_projects)
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

    return {
        "status": "success",
        "message": "User registered successfully",
        "user": {
            "id": user_data["id"],
            "username": user_data["username"],
            "email": user_data["email"],
            "full_name": user_data["full_name"],
        },
    }


@app.post("/api/auth/login")
async def login(user: UserLogin):
    stored_user = users_db.get(user.email)
    if not stored_user or not verify_password(user.password, stored_user["password"]):
        raise HTTPException(status_code=401, detail="Incorrect email or password")

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


@app.get("/api/auth/me")
async def get_current_user_info(request: Request):
    # Get the Authorization header
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid token")
    
    token = auth_header.split(" ")[1]
    
    try:
        # Decode the JWT token
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_email = payload.get("sub")
        
        if not user_email or user_email not in users_db:
            raise HTTPException(status_code=401, detail="Invalid token")
        
        stored_user = users_db[user_email]
        return {
            "id": stored_user["id"],
            "username": stored_user["username"],
            "email": stored_user["email"],
            "full_name": stored_user["full_name"],
        }
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")


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
    # In production, get user from JWT token
    # For now, return all projects (will be filtered by user in production)
    user_projects = [p for p in projects_db if p.get("owner_id") == 1]  # Default to user ID 1
    return {"projects": user_projects}


@app.post("/api/projects")
async def create_project(project_data: dict):
    project = {
        "id": len(projects_db) + 1,
        "title": project_data.get("title", "Untitled Project"),
        "description": project_data.get("description", ""),
        "status": project_data.get("status", "active"),
        "owner_id": project_data.get("owner_id", 1),  # Default to user ID 1
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    projects_db.append(project)
    return {"status": "success", "project": project}


# Task endpoints
@app.get("/api/tasks")
async def get_tasks():
    # In production, get user from JWT token
    # For now, return all tasks (will be filtered by user in production)
    user_tasks = [t for t in tasks_db if t.get("assigned_to") == 1]  # Default to user ID 1
    return {"tasks": user_tasks}


@app.post("/api/tasks")
async def create_task(task_data: dict):
    task = {
        "id": len(tasks_db) + 1,
        "title": task_data.get("title", "Untitled Task"),
        "description": task_data.get("description", ""),
        "project_id": task_data.get("project_id"),
        "assigned_to": task_data.get("assigned_to", 1),  # Default to user ID 1
        "status": task_data.get("status", "todo"),
        "priority": task_data.get("priority", "medium"),
        "created_at": datetime.now(timezone.utc).isoformat(),
        "due_date": task_data.get("due_date"),
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


# Global search endpoint
@app.get("/api/search/global")
async def global_search(q: str):
    if not q or len(q.strip()) < 2:
        return {"projects": [], "tasks": [], "users": []}
    
    query = q.lower().strip()
    results = {
        "projects": [],
        "tasks": [],
        "users": []
    }
    
    # Search in projects
    for project in projects_db:
        if (query in project.get("title", "").lower() or 
            query in project.get("description", "").lower()):
            results["projects"].append({
                "id": project["id"],
                "title": project["title"],
                "description": project.get("description", ""),
                "status": project.get("status", ""),
                "created_at": project.get("created_at", "")
            })
    
    # Search in tasks
    for task in tasks_db:
        if (query in task.get("title", "").lower() or 
            query in task.get("description", "").lower()):
            results["tasks"].append({
                "id": task["id"],
                "title": task["title"],
                "description": task.get("description", ""),
                "status": task.get("status", ""),
                "project_id": task.get("project_id"),
                "created_at": task.get("created_at", "")
            })
    
    # Search in users
    for user in users_db.values():
        if (query in user.get("username", "").lower() or 
            query in user.get("full_name", "").lower() or
            query in user.get("email", "").lower()):
            results["users"].append({
                "id": user["id"],
                "username": user["username"],
                "full_name": user["full_name"],
                "email": user["email"]
            })
    
    return results
