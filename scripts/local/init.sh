#!/bin/bash
# Script d'initialisation du projet IAM 360°

echo "🚀 Initialisation du projet IAM 360° - Kerialis"
echo "================================================"
echo ""

# Vérification Docker
echo "📋 Vérification des prérequis..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé"
    exit 1
fi
echo "✅ Docker installé: $(docker --version)"

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose n'est pas installé"
    exit 1
fi
echo "✅ Docker Compose installé: $(docker-compose --version)"

echo ""
echo "📁 Préparation de l'environnement..."

# Création du .env
ENV_PATH="environments/local/.env"
ENV_EXAMPLE="environments/local/.env.example"

if [ -f "$ENV_PATH" ]; then
    echo "⚠️  Le fichier .env existe déjà"
else
    if [ -f "$ENV_EXAMPLE" ]; then
        cp "$ENV_EXAMPLE" "$ENV_PATH"
        echo "✅ Fichier .env créé"
    fi
fi

# Création de init-db.sql
INIT_DB="environments/local/init-db.sql"
if [ ! -f "$INIT_DB" ]; then
    cat > "$INIT_DB" << 'EOF'
-- IAM 360° - Initialisation PostgreSQL

\c sirh;

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
EOF
    echo "✅ Fichier init-db.sql créé"
fi

# Migration des configs existantes
echo ""
echo "📦 Migration des configurations..."

# MidPoint
mkdir -p services/midpoint/resources
if [ -f "docker/ldap-resource-fixed.xml" ]; then
    cp docker/ldap-resource-fixed.xml services/midpoint/resources/010-resource-ldap.xml
    echo "✅ Ressource LDAP copiée"
fi

# LDAP
mkdir -p services/ldap/init
if [ -f "docker/ldap-init.ldif" ]; then
    cp docker/ldap-init.ldif services/ldap/init/structure.ldif
    echo "✅ Structure LDAP copiée"
fi

# Keycloak
mkdir -p services/keycloak/realms
if [ -f "docker/keycloak-realms/kerialis-realm.json" ]; then
    cp docker/keycloak-realms/kerialis-realm.json services/keycloak/realms/
    echo "✅ Realm Keycloak copié"
fi

echo ""
echo "✅ Configuration terminée !"
echo ""
echo "📋 Prochaines étapes:"
echo "1. Démarrer:  just dev-up"
echo "   ou:        cd environments/local && docker-compose up -d"
echo ""
echo "2. Attendre 2-3 minutes pour l'initialisation"
echo ""
echo "3. Accéder:   http://localhost"
echo ""
echo "4. Logs:      just dev-logs"
echo ""
echo "🎉 Bon test du POC IAM 360° !"
