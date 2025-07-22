import pytest
import os
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.main import app
from app.core.database import get_db, Base

# Create test database - use environment variable if available, otherwise SQLite
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./test.db")

if DATABASE_URL.startswith("sqlite"):
    engine = create_engine(
        DATABASE_URL, connect_args={"check_same_thread": False}
    )
else:
    engine = create_engine(DATABASE_URL)

TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db


@pytest.fixture(scope="function")
def test_db():
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)


client = TestClient(app)


def test_create_project(test_db):
    """Test creating a new project"""
    # First create a user
    user_data = {
        "email": "test@university.edu",
        "username": "testuser",
        "full_name": "Test User",
        "password": "testpassword123",
    }
    user_response = client.post("/api/v1/auth/register", json=user_data)
    assert user_response.status_code == 201

    # Login to get token
    login_data = {
        "username": "testuser",
        "password": "testpassword123",
    }
    login_response = client.post("/api/v1/auth/login", json=login_data)
    assert login_response.status_code == 200
    token = login_response.json()["access_token"]

    # Create project
    project_data = {
        "title": "Test Project",
        "description": "A test project for collaboration",
    }
    headers = {"Authorization": f"Bearer {token}"}
    response = client.post("/api/v1/projects/", json=project_data, headers=headers)
    assert response.status_code == 201
    data = response.json()
    assert data["title"] == project_data["title"]
    assert data["description"] == project_data["description"]
    assert "id" in data


def test_get_projects(test_db):
    """Test getting all projects for a user"""
    # First create a user and login
    user_data = {
        "email": "test@university.edu",
        "username": "testuser",
        "full_name": "Test User",
        "password": "testpassword123",
    }
    client.post("/api/v1/auth/register", json=user_data)

    login_data = {
        "username": "testuser",
        "password": "testpassword123",
    }
    login_response = client.post("/api/v1/auth/login", json=login_data)
    token = login_response.json()["access_token"]

    # Create a project
    project_data = {
        "title": "Test Project",
        "description": "A test project",
    }
    headers = {"Authorization": f"Bearer {token}"}
    client.post("/api/v1/projects/", json=project_data, headers=headers)

    # Get all projects
    response = client.get("/api/v1/projects/", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 1
    assert data[0]["title"] == project_data["title"]


def test_get_project(test_db):
    """Test getting a specific project"""
    # Create user and login
    user_data = {
        "email": "test@university.edu",
        "username": "testuser",
        "full_name": "Test User",
        "password": "testpassword123",
    }
    client.post("/api/v1/auth/register", json=user_data)

    login_data = {
        "username": "testuser",
        "password": "testpassword123",
    }
    login_response = client.post("/api/v1/auth/login", json=login_data)
    token = login_response.json()["access_token"]

    # Create project
    project_data = {
        "title": "Test Project",
        "description": "A test project",
    }
    headers = {"Authorization": f"Bearer {token}"}
    create_response = client.post("/api/v1/projects/", json=project_data, headers=headers)
    project_id = create_response.json()["id"]

    # Get the specific project
    response = client.get(f"/api/v1/projects/{project_id}", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == project_id
    assert data["title"] == project_data["title"]


def test_get_project_not_found(test_db):
    """Test getting a project that doesn't exist"""
    # Create user and login
    user_data = {
        "email": "test@university.edu",
        "username": "testuser",
        "full_name": "Test User",
        "password": "testpassword123",
    }
    client.post("/api/v1/auth/register", json=user_data)

    login_data = {
        "username": "testuser",
        "password": "testpassword123",
    }
    login_response = client.post("/api/v1/auth/login", json=login_data)
    token = login_response.json()["access_token"]

    headers = {"Authorization": f"Bearer {token}"}
    response = client.get("/api/v1/projects/999", headers=headers)
    assert response.status_code == 404
    assert response.json()["detail"] == "Project not found" 