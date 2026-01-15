import pytest
from datetime import datetime

def test_complete_employee_lifecycle(client, sample_employee):
    """Test complete employee lifecycle: onboard -> change -> offboard"""
    # 1. Onboard
    onboard_response = client.post("/employees/onboard", json=sample_employee)
    assert onboard_response.status_code == 200
    employee_id = onboard_response.json()["id"]
    assert onboard_response.json()["status"] == "active"
    
    # 2. Verify employee exists
    get_response = client.get(f"/employees/{employee_id}")
    assert get_response.status_code == 200
    assert get_response.json()["email"] == sample_employee["email"]
    
    # 3. Change department
    change_response = client.post(
        f"/employees/{employee_id}/change",
        json={"new_department": "Management"}
    )
    assert change_response.status_code == 200
    assert change_response.json()["department"] == "Management"
    
    # 4. Change position
    change2_response = client.post(
        f"/employees/{employee_id}/change",
        json={"new_position": "Team Lead"}
    )
    assert change2_response.status_code == 200
    assert change2_response.json()["position"] == "Team Lead"
    
    # 5. Verify changes persisted
    get_response2 = client.get(f"/employees/{employee_id}")
    assert get_response2.json()["department"] == "Management"
    assert get_response2.json()["position"] == "Team Lead"
    
    # 6. Offboard
    offboard_response = client.post(f"/employees/{employee_id}/offboard")
    assert offboard_response.status_code == 200
    assert offboard_response.json()["status"] == "inactive"
    
    # 7. Verify employee still exists but inactive
    final_response = client.get(f"/employees/{employee_id}")
    assert final_response.status_code == 200
    assert final_response.json()["status"] == "inactive"

def test_multiple_employees_scenario(client, sample_employee, sample_employee2):
    """Test scenario with multiple employees"""
    # Onboard two employees
    emp1_response = client.post("/employees/onboard", json=sample_employee)
    emp2_response = client.post("/employees/onboard", json=sample_employee2)
    
    emp1_id = emp1_response.json()["id"]
    emp2_id = emp2_response.json()["id"]
    
    # List should show both
    list_response = client.get("/employees")
    assert len(list_response.json()) == 2
    
    # Offboard first employee
    client.post(f"/employees/{emp1_id}/offboard")
    
    # Both should still be in list
    list_response2 = client.get("/employees")
    employees = list_response2.json()
    assert len(employees) == 2
    
    # One active, one inactive
    statuses = [emp["status"] for emp in employees]
    assert "active" in statuses
    assert "inactive" in statuses

def test_statistics_endpoint(client, sample_employee, sample_employee2):
    """Test statistics aggregation"""
    # Create some employees and perform actions
    emp1_response = client.post("/employees/onboard", json=sample_employee)
    client.post("/employees/onboard", json=sample_employee2)
    
    emp1_id = emp1_response.json()["id"]
    client.post(f"/employees/{emp1_id}/change", json={"new_department": "Sales"})
    client.post(f"/employees/{emp1_id}/offboard")
    
    # Get statistics
    stats_response = client.get("/stats")
    assert stats_response.status_code == 200
    
    stats = stats_response.json()
    assert "total_employees" in stats
    assert "active_employees" in stats
    assert stats["total_employees"] >= 2

def test_concurrent_operations(client, sample_employee):
    """Test handling of operations on same employee"""
    # Onboard employee
    emp_response = client.post("/employees/onboard", json=sample_employee)
    emp_id = emp_response.json()["id"]
    
    # Perform multiple changes quickly
    client.post(f"/employees/{emp_id}/change", json={"new_department": "IT"})
    client.post(f"/employees/{emp_id}/change", json={"new_position": "Senior"})
    client.post(f"/employees/{emp_id}/change", json={"new_department": "HR"})
    
    # Final state should reflect last change
    final = client.get(f"/employees/{emp_id}")
    assert final.json()["department"] == "HR"
    assert final.json()["position"] == "Senior"
