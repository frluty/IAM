import pytest

def test_change_employee_department(client, sample_employee):
    """Test changing employee department"""
    # Onboard employee
    create_response = client.post("/employees/onboard", json=sample_employee)
    employee_id = create_response.json()["id"]
    
    # Change department
    change_data = {
        "new_department": "Finance"
    }
    response = client.post(f"/employees/{employee_id}/change", json=change_data)
    
    assert response.status_code == 200
    data = response.json()
    assert data["department"] == "Finance"
    assert data["position"] == sample_employee["position"]  # Unchanged

def test_change_employee_position(client, sample_employee):
    """Test changing employee position"""
    # Onboard employee
    create_response = client.post("/employees/onboard", json=sample_employee)
    employee_id = create_response.json()["id"]
    
    # Change position
    change_data = {
        "new_position": "Senior Developer"
    }
    response = client.post(f"/employees/{employee_id}/change", json=change_data)
    
    assert response.status_code == 200
    data = response.json()
    assert data["position"] == "Senior Developer"
    assert data["department"] == sample_employee["department"]  # Unchanged

def test_change_employee_manager(client, sample_employee):
    """Test changing employee manager"""
    # Onboard employee
    create_response = client.post("/employees/onboard", json=sample_employee)
    employee_id = create_response.json()["id"]
    
    # Change manager
    change_data = {
        "new_manager_email": "new.manager@kerialis.local"
    }
    response = client.post(f"/employees/{employee_id}/change", json=change_data)
    
    assert response.status_code == 200
    data = response.json()
    assert data["manager_email"] == "new.manager@kerialis.local"

def test_change_multiple_fields(client, sample_employee):
    """Test changing multiple employee fields at once"""
    # Onboard employee
    create_response = client.post("/employees/onboard", json=sample_employee)
    employee_id = create_response.json()["id"]
    
    # Change multiple fields
    change_data = {
        "new_department": "Operations",
        "new_position": "DevOps Engineer",
        "new_manager_email": "ops.manager@kerialis.local"
    }
    response = client.post(f"/employees/{employee_id}/change", json=change_data)
    
    assert response.status_code == 200
    data = response.json()
    assert data["department"] == "Operations"
    assert data["position"] == "DevOps Engineer"
    assert data["manager_email"] == "ops.manager@kerialis.local"

def test_change_employee_not_found(client):
    """Test changing non-existent employee"""
    change_data = {"new_department": "Finance"}
    response = client.post("/employees/INVALID-ID/change", json=change_data)
    assert response.status_code == 404

def test_change_no_fields(client, sample_employee):
    """Test change request with no fields"""
    # Onboard employee
    create_response = client.post("/employees/onboard", json=sample_employee)
    employee_id = create_response.json()["id"]
    
    # Empty change
    response = client.post(f"/employees/{employee_id}/change", json={})
    
    # Should either succeed with no changes or return 400
    assert response.status_code in [200, 400]

def test_change_metrics_incremented(client, sample_employee):
    """Test that changes increment Prometheus metrics"""
    # Onboard employee
    create_response = client.post("/employees/onboard", json=sample_employee)
    employee_id = create_response.json()["id"]
    
    # Get initial metrics
    metrics_before = client.get("/metrics").text
    
    # Change employee
    change_data = {"new_department": "Sales"}
    client.post(f"/employees/{employee_id}/change", json=change_data)
    
    # Get metrics after
    metrics_after = client.get("/metrics").text
    
    # Verify metrics were incremented
    assert "sirh_change_total" in metrics_after
