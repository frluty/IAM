import pytest
from fastapi.testclient import TestClient
from main import app, employees_db, employee_counter

@pytest.fixture
def client():
    """Test client for API"""
    return TestClient(app)

@pytest.fixture(autouse=True)
def reset_database():
    """Reset in-memory database before each test"""
    employees_db.clear()
    globals()['employee_counter'] = 1
    yield
    employees_db.clear()

@pytest.fixture
def sample_employee():
    """Sample employee data for testing"""
    return {
        "first_name": "Jean",
        "last_name": "Dupont",
        "email": "jean.dupont@kerialis.local",
        "department": "IT",
        "position": "Developer",
        "start_date": "2026-01-15T09:00:00",
        "manager_email": "manager@kerialis.local"
    }

@pytest.fixture
def sample_employee2():
    """Another sample employee"""
    return {
        "first_name": "Marie",
        "last_name": "Martin",
        "email": "marie.martin@kerialis.local",
        "department": "HR",
        "position": "HR Manager",
        "start_date": "2026-01-15T09:00:00"
    }
