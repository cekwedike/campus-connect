from fastapi.testclient import TestClient
from app.main import app
import os
import tempfile
import shutil

# Create a temporary directory for test data
test_data_dir = tempfile.mkdtemp()

# Override the data directory for tests
os.environ['TEST_DATA_DIR'] = test_data_dir

client = TestClient(app)


def test_register_user():
    """Test user registration"""
    user_data = {
        "username": "newtestuser",
        "email": "newtest@example.com",
        "password": "testpassword",
        "full_name": "New Test User"
    }
    
    response = client.post("/api/auth/register", json=user_data)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert data["user"]["email"] == user_data["email"]
    # Note: access_token is not returned in register response anymore


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


# Cleanup after tests
def cleanup():
    """Clean up test data directory"""
    if os.path.exists(test_data_dir):
        shutil.rmtree(test_data_dir) 