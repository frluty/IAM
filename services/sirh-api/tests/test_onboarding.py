import pytest
from datetime import datetime

def test_health_check(client):
    """Test health endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_root_endpoint(client):
    """Test root endpoint"""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["service"] == "SIRH API - IAM 360°"
    assert data["version"] == "1.0.0"

def test_onboard_employee_success(client, sample_employee):
    """Test successful employee onboarding"""
    response = client.post("/employees/onboard", json=sample_employee)
    
    assert response.status_code == 200
    data = response.json()
    
    # Verify returned data
    assert data["id"] is not None
    assert data["first_name"] == sample_employee["first_name"]
    assert data["last_name"] == sample_employee["last_name"]
    assert data["email"] == sample_employee["email"]
    assert data["department"] == sample_employee["department"]
    assert data["position"] == sample_employee["position"]
    assert data["status"] == "active"

def test_onboard_employee_invalid_email(client, sample_employee):
    """Test onboarding with invalid email"""
    sample_employee["email"] = "invalid-email"
    response = client.post("/employees/onboard", json=sample_employee)
    
    assert response.status_code == 422  # Validation error

def test_onboard_employee_missing_fields(client):
    """Test onboarding with missing required fields"""
    incomplete_data = {
        "first_name": "John",
        "last_name": "Doe"
    }
    response = client.post("/employees/onboard", json=incomplete_data)
    
    assert response.status_code == 422

def test_onboard_multiple_employees(client, sample_employee, sample_employee2):
    """Test onboarding multiple employees"""
    # Onboard first employee
    response1 = client.post("/employees/onboard", json=sample_employee)
    assert response1.status_code == 200
    employee1_id = response1.json()["id"]
    
    # Onboard second employee
    response2 = client.post("/employees/onboard", json=sample_employee2)
    assert response2.status_code == 200
    employee2_id = response2.json()["id"]
    
    # Verify different IDs
    assert employee1_id != employee2_id
    
    # Verify both exist in list
    list_response = client.get("/employees")
    assert list_response.status_code == 200
    employees = list_response.json()
    assert len(employees) == 2

def test_list_employees_empty(client):
    """Test listing employees when none exist"""
    response = client.get("/employees")
    assert response.status_code == 200
    assert response.json() == []

def test_list_employees_with_data(client, sample_employee):
    """Test listing employees after onboarding"""
    # Create employee
    client.post("/employees/onboard", json=sample_employee)
    
    # List employees
    response = client.get("/employees")
    assert response.status_code == 200
    employees = response.json()
    assert len(employees) == 1
    assert employees[0]["email"] == sample_employee["email"]

def test_get_employee_by_id(client, sample_employee):
    """Test getting specific employee by ID"""
    # Create employee
    create_response = client.post("/employees/onboard", json=sample_employee)
    employee_id = create_response.json()["id"]
    
    # Get employee
    response = client.get(f"/employees/{employee_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == employee_id
    assert data["email"] == sample_employee["email"]

def test_get_employee_not_found(client):
    """Test getting non-existent employee"""
    response = client.get("/employees/INVALID-ID")
    assert response.status_code == 404

def test_onboarding_metrics_incremented(client, sample_employee):
    """Test that onboarding increments Prometheus metrics"""
    # Get initial metrics
    metrics_before = client.get("/metrics").text
    
    # Onboard employee
    client.post("/employees/onboard", json=sample_employee)
    
    # Get metrics after
    metrics_after = client.get("/metrics").text
    
    # Verify metrics were incremented
    assert "sirh_onboarding_total" in metrics_after
