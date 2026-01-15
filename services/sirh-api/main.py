from fastapi import FastAPI, BackgroundTasks
from pydantic import BaseModel
from datetime import datetime
import httpx
import logging
import json

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

MIDPOINT_URL = "http://midpoint:8080/midpoint"
MIDPOINT_USER = "administrator"
MIDPOINT_PASSWORD = "5ecr3t"

app = FastAPI(title="SIRH API")
employees_db = {}

class Employee(BaseModel):
    first_name: str
    last_name: str
    email: str
    department: str
    position: str

async def sync_to_systems(employee: Employee):
    """Create user in MidPoint → auto-provision to LDAP"""
    username = employee.email.split("@")[0]
    
    try:
        midpoint_xml = f"""<?xml version="1.0"?>
<user xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3"
      xmlns:c="http://midpoint.evolveum.com/xml/ns/public/common/common-3">
    <name>{username}</name>
    <fullName>{employee.first_name} {employee.last_name}</fullName>
    <givenName>{employee.first_name}</givenName>
    <familyName>{employee.last_name}</familyName>
    <emailAddress>{employee.email}</emailAddress>
    <organizationalUnit>{employee.department}</organizationalUnit>
    <title>{employee.position}</title>
    <credentials><password><value>Welcome2026!</value></password></credentials>
    <activation><administrativeStatus>enabled</administrativeStatus></activation>
    <assignment>
        <construction>
            <resourceRef oid="8a83b1a4-be18-11d0-a765-123478563412" type="c:ResourceType"/>
        </construction>
    </assignment>
</user>"""
        
        async with httpx.AsyncClient(timeout=30) as client:
            resp = await client.post(
                f"{MIDPOINT_URL}/ws/rest/users",
                content=midpoint_xml,
                headers={"Content-Type": "application/xml"},
                auth=(MIDPOINT_USER, MIDPOINT_PASSWORD)
            )
            
            if resp.status_code not in [200, 201, 204]:
                logger.error(f"MidPoint error {resp.status_code}: {employee.email}")
                return
            
            logger.info(f"✅ Created {employee.email} → MidPoint → LDAP")
        
    except Exception as e:
        logger.error(f"Error {employee.email}: {str(e)}")

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.post("/onboard")
async def onboard(employee: Employee, bg: BackgroundTasks):
    employees_db[employee.email] = employee
    bg.add_task(sync_to_systems, employee)
    return {"status": "onboarding", "email": employee.email}

@app.get("/employees")
async def list_employees():
    return list(employees_db.values())
