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

# File paths for persistence
DATA_DIR = os.getenv("TEST_DATA_DIR", "/tmp/data")  # Use /tmp which is always writable
USERS_FILE = os.path.join(DATA_DIR, "users.json")
PROJECTS_FILE = os.path.join(DATA_DIR, "projects.json")
TASKS_FILE = os.path.join(DATA_DIR, "tasks.json")

# Create data directory if it doesn't exist
try:
    os.makedirs(DATA_DIR, exist_ok=True)
    print(f"✅ Data directory created/verified: {DATA_DIR}")
except Exception as e:
    print(f"⚠️ Warning: Could not create data directory {DATA_DIR}: {e}")
    # Fallback to current working directory
    DATA_DIR = os.path.join(os.getcwd(), "data")
    USERS_FILE = os.path.join(DATA_DIR, "users.json")
    PROJECTS_FILE = os.path.join(DATA_DIR, "projects.json")
    TASKS_FILE = os.path.join(DATA_DIR, "tasks.json")
    try:
        os.makedirs(DATA_DIR, exist_ok=True)
        print(f"✅ Fallback data directory created: {DATA_DIR}")
    except Exception as e2:
        print(f"❌ Critical: Could not create fallback data directory: {e2}")
        # Use in-memory storage as last resort
        DATA_DIR = None
        USERS_FILE = None
        PROJECTS_FILE = None
        TASKS_FILE = None


# Helper functions for file persistence
def load_data(file_path, default_value):
    """Load data from JSON file"""
    if file_path is None:
        return default_value
    try:
        if os.path.exists(file_path):
            with open(file_path, "r") as f:
                return json.load(f)
    except Exception as e:
        print(f"Error loading {file_path}: {e}")
    return default_value


def save_data(file_path, data):
    """Save data to JSON file"""
    if file_path is None:
        print("⚠️ Warning: File persistence disabled, data not saved")
        return
    try:
        with open(file_path, "w") as f:
            json.dump(data, f, indent=2, default=str)
    except Exception as e:
        print(f"Error saving {file_path}: {e}")


# Load existing data or initialize with defaults
print("🔄 Loading data from files...")
users_db = load_data(USERS_FILE, {})
projects_db = load_data(PROJECTS_FILE, [])
tasks_db = load_data(TASKS_FILE, [])
print(f"✅ Loaded {len(users_db)} users, {len(projects_db)} projects, {len(tasks_db)} tasks")

# Add a test user if it doesn't exist
if "test@example.com" not in users_db:
    print("👤 Creating test user...")
    test_user = {
        "id": 1,
        "username": "testuser",
        "email": "test@example.com",
        "password": "testpassword",  # In production, hash this
        "full_name": "Test User",
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    users_db["test@example.com"] = test_user
    save_data(USERS_FILE, users_db)
    print("✅ Test user created")

print("🚀 Backend startup complete!")

# Add sample data to databases
# Note: Sample data removed - users will only see their own projects and tasks


# Pydantic models
class UserRegister(BaseModel):
    username: str
    email: str
    password: str
    full_name: str


class UserLogin(BaseModel):
    email: str
    password: str


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
    save_data(USERS_FILE, users_db)

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
    except jwt.InvalidTokenError:
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
async def get_projects(request: Request):
    # Get the current user from JWT token
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid token")

    token = auth_header.split(" ")[1]
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_email = payload.get("sub")
        if not user_email or user_email not in users_db:
            raise HTTPException(status_code=401, detail="Invalid token")

        current_user = users_db[user_email]
        user_projects = [
            p for p in projects_db if p.get("owner_id") == current_user["id"]
        ]
        return {"projects": user_projects}
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")


@app.get("/api/projects/{project_id}")
async def get_project(project_id: int, request: Request):
    # Get the current user from JWT token
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid token")

    token = auth_header.split(" ")[1]
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_email = payload.get("sub")
        if not user_email or user_email not in users_db:
            raise HTTPException(status_code=401, detail="Invalid token")

        current_user = users_db[user_email]

        # Find the project
        project = next((p for p in projects_db if p["id"] == project_id), None)
        if not project:
            raise HTTPException(status_code=404, detail="Project not found")

        # Check if user owns the project
        if project.get("owner_id") != current_user["id"]:
            raise HTTPException(status_code=403, detail="Access denied")

        return project
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")


@app.post("/api/projects")
async def create_project(project_data: dict, request: Request):
    # Get the current user from JWT token
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid token")

    token = auth_header.split(" ")[1]
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_email = payload.get("sub")
        if not user_email or user_email not in users_db:
            raise HTTPException(status_code=401, detail="Invalid token")

        current_user = users_db[user_email]

        project = {
            "id": len(projects_db) + 1,
            "title": project_data.get("title", "Untitled Project"),
            "description": project_data.get("description", ""),
            "status": project_data.get("status", "active"),
            "owner_id": current_user["id"],
            "created_at": datetime.now(timezone.utc).isoformat(),
        }
        projects_db.append(project)
        save_data(PROJECTS_FILE, projects_db)
        return project
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")


@app.put("/api/projects/{project_id}")
async def update_project(project_id: int, project_data: dict, request: Request):
    # Get the current user from JWT token
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid token")

    token = auth_header.split(" ")[1]
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_email = payload.get("sub")
        if not user_email or user_email not in users_db:
            raise HTTPException(status_code=401, detail="Invalid token")

        current_user = users_db[user_email]

        # Find the project
        project = next((p for p in projects_db if p["id"] == project_id), None)
        if not project:
            raise HTTPException(status_code=404, detail="Project not found")

        # Check if user owns the project
        if project.get("owner_id") != current_user["id"]:
            raise HTTPException(status_code=403, detail="Access denied")

        # Update the project
        project.update(
            {
                "title": project_data.get("title", project["title"]),
                "description": project_data.get("description", project["description"]),
                "status": project_data.get("status", project["status"]),
            }
        )
        save_data(PROJECTS_FILE, projects_db)

        return project
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")


@app.delete("/api/projects/{project_id}")
async def delete_project(project_id: int, request: Request):
    # Get the current user from JWT token
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid token")

    token = auth_header.split(" ")[1]
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_email = payload.get("sub")
        if not user_email or user_email not in users_db:
            raise HTTPException(status_code=401, detail="Invalid token")

        current_user = users_db[user_email]

        # Find the project
        project = next((p for p in projects_db if p["id"] == project_id), None)
        if not project:
            raise HTTPException(status_code=404, detail="Project not found")

        # Check if user owns the project
        if project.get("owner_id") != current_user["id"]:
            raise HTTPException(status_code=403, detail="Access denied")

        # Remove the project
        projects_db.remove(project)
        save_data(PROJECTS_FILE, projects_db)

        # Also remove associated tasks
        tasks_to_remove = [t for t in tasks_db if t.get("project_id") == project_id]
        for task in tasks_to_remove:
            tasks_db.remove(task)
        save_data(TASKS_FILE, tasks_db)

        return {"message": "Project deleted successfully"}
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")


# Task endpoints
@app.get("/api/tasks")
async def get_tasks(request: Request):
    # Get the current user from JWT token
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid token")

    token = auth_header.split(" ")[1]
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_email = payload.get("sub")
        if not user_email or user_email not in users_db:
            raise HTTPException(status_code=401, detail="Invalid token")

        current_user = users_db[user_email]
        user_tasks = [t for t in tasks_db if t.get("assigned_to") == current_user["id"]]
        return {"tasks": user_tasks}
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")


@app.get("/api/tasks/{task_id}")
async def get_task(task_id: int, request: Request):
    # Get the current user from JWT token
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid token")

    token = auth_header.split(" ")[1]
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_email = payload.get("sub")
        if not user_email or user_email not in users_db:
            raise HTTPException(status_code=401, detail="Invalid token")

        current_user = users_db[user_email]

        # Find the task
        task = next((t for t in tasks_db if t["id"] == task_id), None)
        if not task:
            raise HTTPException(status_code=404, detail="Task not found")

        # Check if user is assigned to the task
        if task.get("assigned_to") != current_user["id"]:
            raise HTTPException(status_code=403, detail="Access denied")

        return task
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")


@app.post("/api/tasks")
async def create_task(task_data: dict, request: Request):
    # Get the current user from JWT token
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid token")

    token = auth_header.split(" ")[1]
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_email = payload.get("sub")
        if not user_email or user_email not in users_db:
            raise HTTPException(status_code=401, detail="Invalid token")

        current_user = users_db[user_email]

        task = {
            "id": len(tasks_db) + 1,
            "title": task_data.get("title", "Untitled Task"),
            "description": task_data.get("description", ""),
            "project_id": task_data.get("project_id"),
            "assigned_to": current_user["id"],
            "status": task_data.get("status", "todo"),
            "priority": task_data.get("priority", "medium"),
            "created_at": datetime.now(timezone.utc).isoformat(),
            "due_date": task_data.get("due_date"),
        }
        tasks_db.append(task)
        save_data(TASKS_FILE, tasks_db)
        return task
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")


@app.put("/api/tasks/{task_id}")
async def update_task(task_id: int, task_data: dict, request: Request):
    # Get the current user from JWT token
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid token")

    token = auth_header.split(" ")[1]
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_email = payload.get("sub")
        if not user_email or user_email not in users_db:
            raise HTTPException(status_code=401, detail="Invalid token")

        current_user = users_db[user_email]

        # Find the task
        task = next((t for t in tasks_db if t["id"] == task_id), None)
        if not task:
            raise HTTPException(status_code=404, detail="Task not found")

        # Check if user is assigned to the task
        if task.get("assigned_to") != current_user["id"]:
            raise HTTPException(status_code=403, detail="Access denied")

        # Update the task
        task.update(
            {
                "title": task_data.get("title", task["title"]),
                "description": task_data.get("description", task["description"]),
                "status": task_data.get("status", task["status"]),
                "priority": task_data.get("priority", task["priority"]),
                "due_date": task_data.get("due_date", task["due_date"]),
            }
        )
        save_data(TASKS_FILE, tasks_db)

        return task
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")


@app.delete("/api/tasks/{task_id}")
async def delete_task(task_id: int, request: Request):
    # Get the current user from JWT token
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid token")

    token = auth_header.split(" ")[1]
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_email = payload.get("sub")
        if not user_email or user_email not in users_db:
            raise HTTPException(status_code=401, detail="Invalid token")

        current_user = users_db[user_email]

        # Find the task
        task = next((t for t in tasks_db if t["id"] == task_id), None)
        if not task:
            raise HTTPException(status_code=404, detail="Task not found")

        # Check if user is assigned to the task
        if task.get("assigned_to") != current_user["id"]:
            raise HTTPException(status_code=403, detail="Access denied")

        # Remove the task
        tasks_db.remove(task)
        save_data(TASKS_FILE, tasks_db)

        return {"message": "Task deleted successfully"}
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")


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
    results = {"projects": [], "tasks": [], "users": []}

    # Search in projects
    for project in projects_db:
        if (
            query in project.get("title", "").lower()
            or query in project.get("description", "").lower()
        ):
            results["projects"].append(
                {
                    "id": project["id"],
                    "title": project["title"],
                    "description": project.get("description", ""),
                    "status": project.get("status", ""),
                    "created_at": project.get("created_at", ""),
                }
            )

    # Search in tasks
    for task in tasks_db:
        if (
            query in task.get("title", "").lower()
            or query in task.get("description", "").lower()
        ):
            results["tasks"].append(
                {
                    "id": task["id"],
                    "title": task["title"],
                    "description": task.get("description", ""),
                    "status": task.get("status", ""),
                    "project_id": task.get("project_id"),
                    "created_at": task.get("created_at", ""),
                }
            )

    # Search in users
    for user in users_db.values():
        if (
            query in user.get("username", "").lower()
            or query in user.get("full_name", "").lower()
            or query in user.get("email", "").lower()
        ):
            results["users"].append(
                {
                    "id": user["id"],
                    "username": user["username"],
                    "full_name": user["full_name"],
                    "email": user["email"],
                }
            )

    return results
