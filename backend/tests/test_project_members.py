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


def test_add_project_member(test_db):
    """Test adding a member to a project"""
    # First create two users
    user1_data = {
        "email": "user1@university.edu",
        "username": "user1",
        "full_name": "User One",
        "password": "testpassword123",
    }
    user2_data = {
        "email": "user2@university.edu",
        "username": "user2",
        "full_name": "User Two",
        "password": "testpassword123",
    }
    
    client.post("/api/v1/auth/register", json=user1_data)
    client.post("/api/v1/auth/register", json=user2_data)

    # Login as user1
    login_data = {
        "username": "user1",
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
    project_response = client.post("/api/v1/projects/", json=project_data, headers=headers)
    project_id = project_response.json()["id"]

    # Get user2's ID
    users_response = client.get("/api/v1/users/", headers=headers)
    user2 = next(user for user in users_response.json() if user["username"] == "user2")

    # Add user2 to the project
    member_data = {
        "project_id": project_id,
        "user_id": user2["id"],
        "role": "member"
    }
    response = client.post("/api/v1/project-members/", json=member_data, headers=headers)
    assert response.status_code == 201
    data = response.json()
    assert data["project_id"] == project_id
    assert data["user_id"] == user2["id"]
    assert data["role"] == "member"


def test_get_project_members(test_db):
    """Test getting all members of a project"""
    # First create two users
    user1_data = {
        "email": "user1@university.edu",
        "username": "user1",
        "full_name": "User One",
        "password": "testpassword123",
    }
    user2_data = {
        "email": "user2@university.edu",
        "username": "user2",
        "full_name": "User Two",
        "password": "testpassword123",
    }
    
    client.post("/api/v1/auth/register", json=user1_data)
    client.post("/api/v1/auth/register", json=user2_data)

    # Login as user1
    login_data = {
        "username": "user1",
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
    project_response = client.post("/api/v1/projects/", json=project_data, headers=headers)
    project_id = project_response.json()["id"]

    # Get user2's ID
    users_response = client.get("/api/v1/users/", headers=headers)
    user2 = next(user for user in users_response.json() if user["username"] == "user2")

    # Add user2 to the project
    member_data = {
        "project_id": project_id,
        "user_id": user2["id"],
        "role": "member"
    }
    client.post("/api/v1/project-members/", json=member_data, headers=headers)

    # Get all project members
    response = client.get(f"/api/v1/project-members/project/{project_id}", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 1


def test_get_user_projects(test_db):
    """Test getting all projects a user is a member of"""
    # First create two users
    user1_data = {
        "email": "user1@university.edu",
        "username": "user1",
        "full_name": "User One",
        "password": "testpassword123",
    }
    user2_data = {
        "email": "user2@university.edu",
        "username": "user2",
        "full_name": "User Two",
        "password": "testpassword123",
    }
    
    client.post("/api/v1/auth/register", json=user1_data)
    client.post("/api/v1/auth/register", json=user2_data)

    # Login as user1
    login_data = {
        "username": "user1",
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
    project_response = client.post("/api/v1/projects/", json=project_data, headers=headers)
    project_id = project_response.json()["id"]

    # Get user2's ID
    users_response = client.get("/api/v1/users/", headers=headers)
    user2 = next(user for user in users_response.json() if user["username"] == "user2")

    # Add user2 to the project
    member_data = {
        "project_id": project_id,
        "user_id": user2["id"],
        "role": "member"
    }
    client.post("/api/v1/project-members/", json=member_data, headers=headers)

    # Get all projects for user2
    response = client.get(f"/api/v1/project-members/user/{user2['id']}", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 1


def test_remove_project_member(test_db):
    """Test removing a member from a project"""
    # First create two users
    user1_data = {
        "email": "user1@university.edu",
        "username": "user1",
        "full_name": "User One",
        "password": "testpassword123",
    }
    user2_data = {
        "email": "user2@university.edu",
        "username": "user2",
        "full_name": "User Two",
        "password": "testpassword123",
    }
    
    client.post("/api/v1/auth/register", json=user1_data)
    client.post("/api/v1/auth/register", json=user2_data)

    # Login as user1
    login_data = {
        "username": "user1",
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
    project_response = client.post("/api/v1/projects/", json=project_data, headers=headers)
    project_id = project_response.json()["id"]

    # Get user2's ID
    users_response = client.get("/api/v1/users/", headers=headers)
    user2 = next(user for user in users_response.json() if user["username"] == "user2")

    # Add user2 to the project
    member_data = {
        "project_id": project_id,
        "user_id": user2["id"],
        "role": "member"
    }
    client.post("/api/v1/project-members/", json=member_data, headers=headers)

    # Remove user2 from the project
    response = client.delete(f"/api/v1/project-members/project/{project_id}/user/{user2['id']}", headers=headers)
    assert response.status_code == 204 