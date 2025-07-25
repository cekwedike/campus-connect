#!/usr/bin/env python3
"""
Simple Backend Server for CampusConnect
Run this locally: python run-backend-local.py
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn
from datetime import datetime, timedelta
import jwt
import json

app = FastAPI(
    title="CampusConnect API",
    description="Simple backend for university student collaboration",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://127.0.0.1:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Secret key for JWT
SECRET_KEY = "your-secret-key-here"
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

# In-memory storage
users_db = {}
projects_db = []
tasks_db = []

# Helper functions
def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=30)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def verify_password(plain_password, hashed_password):
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
    
    user_data = {
        "id": len(users_db) + 1,
        "username": user.username,
        "email": user.email,
        "password": user.password,
        "full_name": user.full_name,
        "created_at": datetime.utcnow().isoformat()
    }
    
    users_db[user.email] = user_data
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
            "full_name": user_data["full_name"]
        }
    }

@app.post("/api/auth/login")
async def login(user: UserLogin):
    if user.email not in users_db:
        raise HTTPException(status_code=401, detail="Invalid email or password")
    
    stored_user = users_db[user.email]
    if not verify_password(user.password, stored_user["password"]):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    
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
            "full_name": stored_user["full_name"]
        }
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
                "full_name": user["full_name"]
            }
            for user in users_db.values()
        ]
    }

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
        "created_at": datetime.utcnow().isoformat()
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
        "created_at": datetime.utcnow().isoformat()
    }
    tasks_db.append(task)
    return {"status": "success", "task": task}

if __name__ == "__main__":
    print("🚀 Starting CampusConnect Backend Server...")
    print("📍 Backend will be available at: http://localhost:8000")
    print("📖 API Documentation at: http://localhost:8000/docs")
    print("🔗 Frontend should connect to: http://localhost:8000")
    print("\nPress Ctrl+C to stop the server")
    
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True) 