from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import os
import psycopg2
from psycopg2.extras import RealDictCursor
import json

app = FastAPI(
    title="CampusConnect API",
    description="A simple working backend for university student collaboration",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Database connection function
def get_db_connection():
    try:
        # Get database URL from environment variable
        database_url = os.getenv("DATABASE_URL", "postgresql://postgres:postgres@db/campus_connect")
        
        # Parse the DATABASE_URL
        if database_url.startswith("postgresql://"):
            # Extract components from DATABASE_URL
            parts = database_url.replace("postgresql://", "").split("@")
            if len(parts) == 2:
                user_pass = parts[0].split(":")
                host_port_db = parts[1].split("/")
                
                if len(user_pass) == 2 and len(host_port_db) == 2:
                    user = user_pass[0]
                    password = user_pass[1]
                    host_port = host_port_db[0].split(":")
                    host = host_port[0]
                    port = host_port[1] if len(host_port) > 1 else "5432"
                    database = host_port_db[1]
                    
                    conn = psycopg2.connect(
                        host=host,
                        port=port,
                        database=database,
                        user=user,
                        password=password,
                        cursor_factory=RealDictCursor
                    )
                    return conn
    except Exception as e:
        print(f"Database connection error: {e}")
        return None

# Health check endpoint
@app.get("/")
async def root():
    return {"message": "Welcome to CampusConnect API", "status": "running"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "message": "Backend is running"}

@app.get("/ping")
async def ping():
    return {"message": "pong"}

# Test database connection
@app.get("/test-db")
async def test_database():
    try:
        conn = get_db_connection()
        if conn:
            with conn.cursor() as cur:
                cur.execute("SELECT version();")
                version = cur.fetchone()
                conn.close()
                return {"status": "success", "database": "connected", "version": version}
        else:
            return {"status": "error", "database": "connection failed"}
    except Exception as e:
        return {"status": "error", "database": "error", "message": str(e)}

# Simple user endpoints
@app.get("/api/users")
async def get_users():
    try:
        conn = get_db_connection()
        if conn:
            with conn.cursor() as cur:
                cur.execute("SELECT * FROM users LIMIT 10;")
                users = cur.fetchall()
                conn.close()
                return {"users": [dict(user) for user in users]}
        else:
            return {"users": [], "message": "Database not connected"}
    except Exception as e:
        return {"users": [], "error": str(e)}

@app.post("/api/users")
async def create_user(user_data: dict):
    try:
        conn = get_db_connection()
        if conn:
            with conn.cursor() as cur:
                cur.execute(
                    "INSERT INTO users (username, email, full_name) VALUES (%s, %s, %s) RETURNING id;",
                    (user_data.get("username"), user_data.get("email"), user_data.get("full_name"))
                )
                user_id = cur.fetchone()["id"]
                conn.commit()
                conn.close()
                return {"status": "success", "user_id": user_id}
        else:
            return {"status": "error", "message": "Database not connected"}
    except Exception as e:
        return {"status": "error", "message": str(e)}

# Environment info endpoint
@app.get("/api/info")
async def get_info():
    return {
        "database_url": os.getenv("DATABASE_URL", "not set"),
        "environment": os.getenv("ENVIRONMENT", "development"),
        "cors_origins": os.getenv("BACKEND_CORS_ORIGINS", "not set")
    }
