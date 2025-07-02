import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.main import app
from app.core.database import get_db, Base

# Create test database
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)
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


def test_create_user(test_db):
    """Test creating a new user"""
    user_data = {
        "email": "test@university.edu",
        "username": "testuser",
        "full_name": "Test User",
        "password": "testpassword123",
    }
    response = client.post("/api/v1/users/", json=user_data)
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == user_data["email"]
    assert data["username"] == user_data["username"]
    assert data["full_name"] == user_data["full_name"]
    assert "id" in data
    assert "hashed_password" not in data


def test_get_users(test_db):
    """Test getting all users"""
    # First create a user
    user_data = {
        "email": "test@university.edu",
        "username": "testuser",
        "full_name": "Test User",
        "password": "testpassword123",
    }
    client.post("/api/v1/users/", json=user_data)

    # Then get all users
    response = client.get("/api/v1/users/")
    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 1
    assert data[0]["email"] == user_data["email"]


def test_get_user(test_db):
    """Test getting a specific user"""
    # First create a user
    user_data = {
        "email": "test@university.edu",
        "username": "testuser",
        "full_name": "Test User",
        "password": "testpassword123",
    }
    create_response = client.post("/api/v1/users/", json=user_data)
    user_id = create_response.json()["id"]

    # Then get the specific user
    response = client.get(f"/api/v1/users/{user_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == user_id
    assert data["email"] == user_data["email"]


def test_get_user_not_found(test_db):
    """Test getting a user that doesn't exist"""
    response = client.get("/api/v1/users/999")
    assert response.status_code == 404
    assert response.json()["detail"] == "User not found"
