import os
import tempfile
import shutil

# Create a temporary directory for test data and set environment variable BEFORE importing app
test_data_dir = tempfile.mkdtemp()
os.environ['TEST_DATA_DIR'] = test_data_dir

from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_read_root():
    """Test the root endpoint"""
    response = client.get("/")
    assert response.status_code == 200
    assert "message" in response.json()
    assert "status" in response.json()


def test_health_check():
    """Test the health check endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy", "message": "Backend is running"}


def test_ping():
    """Test the ping endpoint"""
    response = client.get("/ping")
    assert response.status_code == 200
    assert response.json() == {"message": "pong"}


def test_api_docs():
    """Test that API documentation is accessible"""
    response = client.get("/docs")
    assert response.status_code == 200


def test_openapi_schema():
    """Test that OpenAPI schema is accessible"""
    response = client.get("/openapi.json")
    assert response.status_code == 200
    assert "openapi" in response.json()


def test_get_projects_unauthorized():
    """Test getting projects without authentication"""
    response = client.get("/api/projects")
    assert response.status_code == 401  # Should require authentication


def test_get_tasks_unauthorized():
    """Test getting tasks without authentication"""
    response = client.get("/api/tasks")
    assert response.status_code == 401  # Should require authentication


def test_get_users():
    """Test getting users"""
    response = client.get("/api/users")
    assert response.status_code == 200
    data = response.json()
    assert "users" in data
    assert isinstance(data["users"], list)


def test_get_info():
    """Test getting backend info"""
    response = client.get("/api/info")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "users_count" in data
    assert "projects_count" in data
    assert "tasks_count" in data


# Cleanup after tests
def cleanup():
    """Clean up test data directory"""
    if os.path.exists(test_data_dir):
        shutil.rmtree(test_data_dir)
