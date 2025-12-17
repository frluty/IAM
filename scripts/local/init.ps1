# Script d'initialisation du projet IAM 360°
# Optimisé pour Windows + Docker Desktop

Write-Host "🚀 Initialisation du projet IAM 360° - Kerialis" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Vérification des prérequis
Write-Host "📋 Vérification des prérequis..." -ForegroundColor Yellow

# Docker
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker installé: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker n'est pas installé ou n'est pas dans le PATH" -ForegroundColor Red
    exit 1
}

# Docker Compose
try {
    $composeVersion = docker-compose --version
    Write-Host "✅ Docker Compose installé: $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker Compose n'est pas installé" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📁 Préparation de l'environnement..." -ForegroundColor Yellow

# Création du .env depuis .env.example
$envPath = "environments\local\.env"
$envExamplePath = "environments\local\.env.example"

if (Test-Path $envPath) {
    Write-Host "⚠️  Le fichier .env existe déjà" -ForegroundColor Yellow
} else {
    if (Test-Path $envExamplePath) {
        Copy-Item $envExamplePath $envPath
        Write-Host "✅ Fichier .env créé depuis .env.example" -ForegroundColor Green
    } else {
        Write-Host "⚠️  .env.example introuvable" -ForegroundColor Yellow
    }
}

# Création de init-db.sql pour PostgreSQL
$initDbPath = "environments\local\init-db.sql"

if (-not (Test-Path $initDbPath)) {
    # Créer le fichier SQL avec le contenu approprié pour PostgreSQL
    @"
-- IAM 360° - Initialisation PostgreSQL

-- Les bases de données sont créées via POSTGRES_MULTIPLE_DATABASES
-- ou manuellement si nécessaire

-- Connexion à la base sirh
\c sirh;

-- Tables SIRH
CREATE TABLE IF NOT EXISTS employees (
    id VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    department VARCHAR(50) NOT NULL,
    position VARCHAR(100) NOT NULL,
    manager_email VARCHAR(255),
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_employees_email ON employees(email);
CREATE INDEX IF NOT EXISTS idx_employees_status ON employees(status);

CREATE TABLE IF NOT EXISTS hr_events (
    id SERIAL PRIMARY KEY,
    event_type VARCHAR(50) NOT NULL,
    employee_id VARCHAR(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed BOOLEAN DEFAULT FALSE,
    details JSONB,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_hr_events_timestamp ON hr_events(timestamp);
CREATE INDEX IF NOT EXISTS idx_hr_events_processed ON hr_events(processed);
"@ | Out-File -FilePath $initDbPath -Encoding UTF8
    Write-Host "✅ Fichier init-db.sql créé" -ForegroundColor Green
}

# Copie des fichiers de configuration MidPoint/LDAP
Write-Host ""
Write-Host "📦 Migration des configurations existantes..." -ForegroundColor Yellow

# MidPoint resources
$midpointResourcesPath = "services\midpoint\resources"
if (-not (Test-Path $midpointResourcesPath)) {
    New-Item -ItemType Directory -Path $midpointResourcesPath -Force | Out-Null
}

if (Test-Path "docker\ldap-resource-fixed.xml") {
    Copy-Item "docker\ldap-resource-fixed.xml" "$midpointResourcesPath\010-resource-ldap.xml" -Force
    Write-Host "✅ Copie de la ressource LDAP" -ForegroundColor Green
}

# LDAP init
$ldapInitPath = "services\ldap\init"
if (-not (Test-Path $ldapInitPath)) {
    New-Item -ItemType Directory -Path $ldapInitPath -Force | Out-Null
}

if (Test-Path "docker\ldap-init.ldif") {
    Copy-Item "docker\ldap-init.ldif" "$ldapInitPath\structure.ldif" -Force
    Write-Host "✅ Copie de la structure LDAP" -ForegroundColor Green
}

# Keycloak realms
$keycloakRealmsPath = "services\keycloak\realms"
if (-not (Test-Path $keycloakRealmsPath)) {
    New-Item -ItemType Directory -Path $keycloakRealmsPath -Force | Out-Null
}

if (Test-Path "docker\keycloak-realms\kerialis-realm.json") {
    Copy-Item "docker\keycloak-realms\kerialis-realm.json" "$keycloakRealmsPath\" -Force
    Write-Host "✅ Copie du realm Keycloak" -ForegroundColor Green
}

# Résumé
Write-Host ""
Write-Host "✅ Configuration terminée !" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Prochaines étapes:" -ForegroundColor Cyan
Write-Host "1. Démarrer les services:  " -NoNewline
Write-Host "just dev-up" -ForegroundColor Yellow
Write-Host "   ou:                     " -NoNewline
Write-Host "cd environments\local && docker-compose up -d" -ForegroundColor Yellow
Write-Host ""
Write-Host "2. Attendre 2-3 minutes que tous les services démarrent" -ForegroundColor White
Write-Host ""
Write-Host "3. Accéder au portail:     " -NoNewline
Write-Host "http://localhost" -ForegroundColor Yellow
Write-Host ""
Write-Host "4. Voir les logs:          " -NoNewline
Write-Host "just dev-logs" -ForegroundColor Yellow
Write-Host ""
Write-Host "5. Consulter le README.md pour les tests et la documentation" -ForegroundColor White
Write-Host ""
Write-Host "🎉 Bon test du POC IAM 360° !" -ForegroundColor Green
