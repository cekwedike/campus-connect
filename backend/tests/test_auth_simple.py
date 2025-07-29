from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_register_user():
    """Test user registration"""
    user_data = {
        "username": "testuser",
        "email": "test@example.com",
        "password": "testpassword",
        "full_name": "Test User"
    }
    
    response = client.post("/api/auth/register", json=user_data)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert "access_token" in data
    assert data["user"]["email"] == user_data["email"]


def test_login_user():
    """Test user login"""
    # First register a user
    user_data = {
        "username": "loginuser",
        "email": "login@example.com",
        "password": "loginpassword",
        "full_name": "Login User"
    }
    
    # Register
    client.post("/api/auth/register", json=user_data)
    
    # Login
    login_data = {
        "email": "login@example.com",
        "password": "loginpassword"
    }
    
    response = client.post("/api/auth/login", json=login_data)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert "access_token" in data


def test_login_invalid_credentials():
    """Test login with invalid credentials"""
    login_data = {
        "email": "nonexistent@example.com",
        "password": "wrongpassword"
    }
    
    response = client.post("/api/auth/login", json=login_data)
    assert response.status_code == 401


def test_register_duplicate_email():
    """Test registration with duplicate email"""
    user_data = {
        "username": "duplicateuser",
        "email": "duplicate@example.com",
        "password": "password123",
        "full_name": "Duplicate User"
    }
    
    # Register first time
    response = client.post("/api/auth/register", json=user_data)
    assert response.status_code == 200
    
    # Try to register again with same email
    response = client.post("/api/auth/register", json=user_data)
    assert response.status_code == 400


def test_login_existing_user():
    """Test login with existing test user"""
    login_data = {
        "email": "test@example.com",
        "password": "testpassword"
    }
    
    response = client.post("/api/auth/login", json=login_data)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert "access_token" in data 