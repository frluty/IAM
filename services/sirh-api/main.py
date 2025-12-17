from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
from datetime import datetime, timedelta
from typing import Optional, List
import httpx
import os
import logging
from prometheus_client import Counter, Histogram, generate_latest
from fastapi.responses import Response
import json

# Configuration logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Métriques Prometheus
onboarding_counter = Counter('sirh_onboarding_total', 'Total d\'onboardings effectués')
offboarding_counter = Counter('sirh_offboarding_total', 'Total d\'offboardings effectués')
change_counter = Counter('sirh_change_total', 'Total de changements effectués')
api_latency = Histogram('sirh_api_latency_seconds', 'Latence des appels API')

# Configuration
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:postgres2025@postgres:5432/sirh")
MIDPOINT_URL = os.getenv("MIDPOINT_URL", "http://midpoint:8080/midpoint")
MIDPOINT_USER = os.getenv("MIDPOINT_USER", "administrator")
MIDPOINT_PASSWORD = os.getenv("MIDPOINT_PASSWORD", "5ecr3t")

app = FastAPI(
    title="SIRH API - IAM 360°",
    description="API de gestion des événements RH pour provisioning automatique",
    version="1.0.0"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Modèles Pydantic
class Employee(BaseModel):
    id: Optional[str] = None
    first_name: str
    last_name: str
    email: EmailStr
    department: str
    position: str
    manager_email: Optional[EmailStr] = None
    start_date: datetime
    end_date: Optional[datetime] = None
    status: str = "active"

class OnboardingRequest(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    department: str
    position: str
    start_date: datetime
    manager_email: Optional[EmailStr] = None

class ChangeRequest(BaseModel):
    new_department: Optional[str] = None
    new_position: Optional[str] = None
    new_manager_email: Optional[EmailStr] = None

# Stockage en mémoire (pour la démo)
employees_db = {}
employee_counter = 1

# Endpoints

@app.get("/")
async def root():
    return {
        "service": "SIRH API - IAM 360°",
        "version": "1.0.0",
        "status": "operational",
        "endpoints": {
            "docs": "/docs",
            "health": "/health",
            "metrics": "/metrics"
        }
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}

@app.get("/metrics")
async def metrics():
    """Prometheus metrics endpoint"""
    return Response(content=generate_latest(), media_type="text/plain")

@app.post("/employees/onboard", response_model=Employee)
async def onboard_employee(request: OnboardingRequest, background_tasks: BackgroundTasks):
    """
    Onboarding d'un nouvel employé
    Déclenche automatiquement le provisioning dans MidPoint
    """
    global employee_counter
    
    # Génération ID employé
    employee_id = f"EMP-{employee_counter:04d}"
    employee_counter += 1
    
    # Création employé
    employee = Employee(
        id=employee_id,
        first_name=request.first_name,
        last_name=request.last_name,
        email=request.email,
        department=request.department,
        position=request.position,
        manager_email=request.manager_email,
        start_date=request.start_date,
        status="active"
    )
    
    # Sauvegarde
    employees_db[employee_id] = employee
    
    # Incrémenter métrique
    onboarding_counter.inc()
    
    # Déclencher provisioning MidPoint (en arrière-plan)
    background_tasks.add_task(provision_to_midpoint, employee, "onboard")
    
    logger.info(f"✅ Onboarding: {employee.email} ({employee_id})")
    
    return employee

@app.get("/employees", response_model=List[Employee])
async def list_employees(status: Optional[str] = None):
    """Liste tous les employés"""
    employees = list(employees_db.values())
    
    if status:
        employees = [e for e in employees if e.status == status]
    
    return employees

@app.get("/employees/{employee_id}", response_model=Employee)
async def get_employee(employee_id: str):
    """Récupère un employé par son ID"""
    if employee_id not in employees_db:
        raise HTTPException(status_code=404, detail="Employé non trouvé")
    
    return employees_db[employee_id]

@app.post("/employees/{employee_id}/change", response_model=Employee)
async def change_employee(employee_id: str, request: ChangeRequest, background_tasks: BackgroundTasks):
    """
    Changement de poste/département
    Déclenche la mise à jour des droits dans MidPoint
    """
    if employee_id not in employees_db:
        raise HTTPException(status_code=404, detail="Employé non trouvé")
    
    employee = employees_db[employee_id]
    
    # Mise à jour
    if request.new_department:
        employee.department = request.new_department
    if request.new_position:
        employee.position = request.new_position
    if request.new_manager_email:
        employee.manager_email = request.new_manager_email
    
    # Incrémenter métrique
    change_counter.inc()
    
    # Déclencher mise à jour MidPoint
    background_tasks.add_task(provision_to_midpoint, employee, "change")
    
    logger.info(f"🔄 Changement: {employee.email} - {employee.department}/{employee.position}")
    
    return employee

@app.post("/employees/{employee_id}/offboard", response_model=Employee)
async def offboard_employee(employee_id: str, background_tasks: BackgroundTasks):
    """
    Offboarding d'un employé
    Déclenche la désactivation dans MidPoint
    """
    if employee_id not in employees_db:
        raise HTTPException(status_code=404, detail="Employé non trouvé")
    
    employee = employees_db[employee_id]
    employee.status = "inactive"
    employee.end_date = datetime.now()
    
    # Incrémenter métrique
    offboarding_counter.inc()
    
    # Déclencher désactivation MidPoint
    background_tasks.add_task(provision_to_midpoint, employee, "offboard")
    
    logger.info(f"❌ Offboarding: {employee.email} ({employee_id})")
    
    return employee

@app.delete("/employees/{employee_id}")
async def delete_employee(employee_id: str):
    """Supprime un employé (pour nettoyage démo uniquement)"""
    if employee_id not in employees_db:
        raise HTTPException(status_code=404, detail="Employé non trouvé")
    
    del employees_db[employee_id]
    
    return {"message": f"Employé {employee_id} supprimé"}

@app.get("/stats")
async def get_stats():
    """Statistiques globales"""
    active = len([e for e in employees_db.values() if e.status == "active"])
    inactive = len([e for e in employees_db.values() if e.status == "inactive"])
    
    return {
        "total_employees": len(employees_db),
        "active": active,
        "inactive": inactive,
        "departments": list(set([e.department for e in employees_db.values()]))
    }

# Fonction de provisioning vers MidPoint
async def provision_to_midpoint(employee: Employee, action: str):
    """
    Envoie les événements à MidPoint pour provisioning
    """
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            # Construction de l'objet utilisateur MidPoint
            midpoint_user = {
                "user": {
                    "name": employee.email.split("@")[0],
                    "fullName": f"{employee.first_name} {employee.last_name}",
                    "givenName": employee.first_name,
                    "familyName": employee.last_name,
                    "emailAddress": employee.email,
                    "employeeNumber": employee.id,
                    "organizationalUnit": employee.department,
                    "title": employee.position,
                    "activation": {
                        "administrativeStatus": "enabled" if employee.status == "active" else "disabled"
                    }
                }
            }
            
            logger.info(f"🔄 Provisioning MidPoint ({action}): {employee.email}")
            
            # Simulation d'appel à MidPoint REST API
            # En production, utiliser l'API REST MidPoint
            # POST /midpoint/ws/rest/users
            
            # Pour la démo, on log juste
            logger.info(f"✅ MidPoint provisioning simulé: {json.dumps(midpoint_user, indent=2)}")
            
    except Exception as e:
        logger.error(f"❌ Erreur provisioning MidPoint: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
