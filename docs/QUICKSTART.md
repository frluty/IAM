# IAM 360° - Quick Start Guide

## 🚀 Démarrage Rapide

### Prérequis
- Docker Desktop 20.10+
- PowerShell 5.1+
- Just 1.43.1+ (`winget install --id Casey.Just`)

### Premier Démarrage

1. **Initialiser l'environnement** :
```powershell
cd environments/local
just init
```

2. **Démarrer tous les services** :
```powershell
just dev-up
```

3. **Vérifier l'état des services** :
```powershell
just dev-status
```

## 🔑 Accès aux Services

| Service | URL | Username | Password |
|---------|-----|----------|----------|
| **MidPoint** (IGA) | http://localhost:8080/midpoint/ | `administrator` | `5ecr3t` |
| **Keycloak** (SSO) | http://localhost:8180/ | `admin` | `admin123` |
| **SIRH API** | http://localhost:8000/docs | - | - |
| **Grafana** | http://localhost:3000 | `admin` | `admin` |
| **Prometheus** | http://localhost:9090 | - | - |
| **phpLDAPadmin** | http://localhost:8081 | `cn=admin,dc=kerialis,dc=local` | `admin` |

## 🧪 Tests Fonctionnels

### Test d'onboarding
```powershell
just test-onboard
```

### Test de changement
```powershell
just test-change
```

### Test d'offboarding
```powershell
just test-offboard
```

### Scénario complet
```powershell
just test-scenario
```

## 🗄️ Base de Données PostgreSQL

**Connexion** : `localhost:5432`
**User/Password** : `postgres` / `postgres2025`

**Bases de données** :
- `midpoint` (owner: midpoint)
- `keycloak` (owner: keycloak)
- `sirh` (owner: sirh)

## 📊 Monitoring & Observabilité

### Métriques Prometheus
```powershell
# Voir les métriques SIRH API
curl http://localhost:8000/metrics

# Voir les métriques Prometheus
curl http://localhost:9090/metrics
```

### Logs d'Audit
```powershell
docker exec iam-sirh-api cat /app/audit.log | ConvertFrom-Json
```

### Dashboard Grafana
- Naviguer vers http://localhost:3000
- Aller dans "Dashboards" → "IAM Overview"
- Voir les métriques temps réel : onboarding, offboarding, latence, erreurs

## 🔧 Dépannage

### Les services ne démarrent pas
```powershell
# Voir les logs d'un service spécifique
docker logs iam-midpoint --tail 50

# Redémarrer tous les services
just dev-restart

# Nettoyer et redémarrer complètement
just dev-clean
just dev-up
```

### MidPoint ne démarre pas
```powershell
# Vérifier que la base existe
docker exec iam-postgres psql -U postgres -l | Select-String midpoint

# Si la base n'existe pas, la créer
docker exec iam-postgres psql -U postgres -c "CREATE USER midpoint WITH PASSWORD 'postgres2025'"
docker exec iam-postgres psql -U postgres -c "CREATE DATABASE midpoint OWNER midpoint"

# Réinitialiser MidPoint
docker-compose stop midpoint midpoint_init
docker-compose rm -f midpoint midpoint_init
docker volume rm local_midpoint_home
docker-compose up -d midpoint_init
docker-compose up -d midpoint
```

### Keycloak ne démarre pas
```powershell
# Vérifier que la base existe
docker exec iam-postgres psql -U postgres -l | Select-String keycloak

# Si la base n'existe pas, la créer
docker exec iam-postgres psql -U postgres -c "CREATE USER keycloak WITH PASSWORD 'postgres2025'"
docker exec iam-postgres psql -U postgres -c "CREATE DATABASE keycloak OWNER keycloak"

# Redémarrer Keycloak
docker-compose restart keycloak
```

### LDAP en boucle de redémarrage
```powershell
# Nettoyer et recréer LDAP
docker-compose stop ldap
docker-compose rm -f ldap
docker volume rm local_ldap_data local_ldap_config
docker-compose up -d ldap
```

## 📁 Structure du Projet

```
IAM/
├── environments/local/        # Configuration Docker locale
│   ├── docker-compose.yml    # Orchestration des services
│   └── init-db.sql           # Initialisation PostgreSQL
├── services/                  # Code source des services
│   ├── sirh-api/             # API SIRH (FastAPI)
│   ├── midpoint/resources/   # Ressources MidPoint
│   ├── keycloak/realms/      # Configuration Keycloak
│   └── ldap/init/            # LDIF d'initialisation
├── monitoring/                # Stack monitoring
│   ├── prometheus/           # Métriques & alertes
│   ├── grafana/              # Dashboards
│   └── alertmanager/         # Gestion des alertes
├── scripts/                   # Scripts d'automatisation
└── docs/                      # Documentation
```

## 🎯 Prochaines Étapes

1. **Configurer MidPoint** :
   - Se connecter à http://localhost:8080/midpoint/
   - Importer la ressource LDAP depuis `/opt/midpoint/var/initial-objects/`
   - Créer des rôles et des politiques

2. **Configurer Keycloak** :
   - Se connecter à http://localhost:8180/
   - Créer un nouveau realm "Kerialis"
   - Configurer les clients OAuth2/OIDC

3. **Tester l'intégration complète** :
   ```powershell
   just test-scenario
   ```

4. **Monitorer les opérations** :
   - Ouvrir Grafana : http://localhost:3000
   - Consulter le dashboard "IAM Overview"
   - Vérifier les alertes dans Prometheus

## 📞 Support

- Documentation MidPoint : https://docs.evolveum.com/midpoint/
- Documentation Keycloak : https://www.keycloak.org/documentation
- Repo du projet : [Lien vers votre repo]
