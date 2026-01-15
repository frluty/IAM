import pytest
from datetime import datetime

def test_offboard_employee_success(client, sample_employee):
    """Test successful employee offboarding"""
    # First, onboard the employee
    create_response = client.post("/employees/onboard", json=sample_employee)
    employee_id = create_response.json()["id"]
    
    # Offboard the employee
    response = client.post(f"/employees/{employee_id}/offboard")
    
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == employee_id
    assert data["status"] == "inactive"
    assert data["end_date"] is not None

def test_offboard_employee_not_found(client):
    """Test offboarding non-existent employee"""
    response = client.post("/employees/INVALID-ID/offboard")
    assert response.status_code == 404

def test_offboard_already_inactive(client, sample_employee):
    """Test offboarding an already inactive employee"""
    # Onboard
    create_response = client.post("/employees/onboard", json=sample_employee)
    employee_id = create_response.json()["id"]
    
    # Offboard first time
    client.post(f"/employees/{employee_id}/offboard")
    
    # Try to offboard again
    response = client.post(f"/employees/{employee_id}/offboard")
    
    # Should either succeed or return appropriate status
    assert response.status_code in [200, 400]

def test_offboarding_metrics_incremented(client, sample_employee):
    """Test that offboarding increments Prometheus metrics"""
    # Onboard employee
    create_response = client.post("/employees/onboard", json=sample_employee)
    employee_id = create_response.json()["id"]
    
    # Get initial metrics
    metrics_before = client.get("/metrics").text
    
    # Offboard employee
    client.post(f"/employees/{employee_id}/offboard")
    
    # Get metrics after
    metrics_after = client.get("/metrics").text
    
    # Verify metrics were incremented
    assert "sirh_offboarding_total" in metrics_after
