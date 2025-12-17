# 🔐 IAM 360° - Plateforme de Gestion des Identités

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Docker](https://img.shields.io/badge/docker-ready-blue)

Plateforme complète de gestion des identités et des accès (IAM) intégrant provisioning automatique, SSO, monitoring et gestion des secrets.

## 🎯 Vue d'ensemble

**IAM 360°** est une solution complète démontrant :
- ✅ **IGA (Identity Governance)** avec MidPoint
- ✅ **SSO/IAM** avec Keycloak
- ✅ **Provisioning automatique** depuis événements RH
- ✅ **Gestion des secrets** avec HashiCorp Vault
- ✅ **Monitoring temps réel** avec Prometheus + Grafana
- ✅ **Annuaire LDAP** avec OpenLDAP

## 📊 Architecture

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐
│   SIRH API  │─────▶│   MidPoint   │─────▶│  Keycloak   │
│  (Événements│      │    (IGA)     │      │    (SSO)    │
│     RH)     │      └──────┬───────┘      └──────┬──────┘
└─────────────┘             │                     │
       │                    │                     │
       │            ┌───────▼─────────────────────▼────┐
       │            │        PostgreSQL                │
       │            └──────────────────────────────────┘
       │
       │            ┌──────────────┐      ┌─────────────┐
       └───────────▶│  Prometheus  │─────▶│   Grafana   │
                    │  (Métriques) │      │ (Dashboards)│
                    └──────────────┘      └─────────────┘
```

## 🚀 Démarrage rapide

### Prérequis

- **Docker Desktop** 20.10+
- **Docker Compose** 2.0+
- **Just** (task runner) - `cargo install just` ou `choco install just`
- **8GB RAM** minimum
- **Windows 10/11** avec PowerShell 5.1+

### Installation

```powershell
# 1. Cloner le projet
git clone https://github.com/votre-org/IAM.git
cd IAM

# 2. Initialiser le projet
just init

# 3. Démarrer tous les services
just dev-up

# 4. Attendre 2-3 minutes puis accéder au portail
just open-portal
```

## 🔗 Services disponibles

| Service | URL | Identifiants | Description |
|---------|-----|--------------|-------------|
| **Portail** | http://localhost | - | Page d'accueil centralisée |
| **MidPoint** | http://localhost:8080/midpoint | admin / 5ecr3t | Identity Governance & Administration |
| **Keycloak** | http://localhost:8180 | admin / admin123 | SSO & Access Management |
| **Grafana** | http://localhost:3000 | admin / admin123 | Dashboards & Analytics |
| **SIRH API** | http://localhost:8000/docs | - | API Événements RH (Swagger) |
| **Vault** | http://localhost:8200 | root-token-dev | Secrets Management |
| **phpLDAPadmin** | http://localhost:8090 | cn=admin,dc=kerialis,dc=local / admin | Gestion LDAP |
| **Prometheus** | http://localhost:9090 | - | Métriques & Monitoring |

## 📖 Commandes principales

### Développement local

```powershell
# Initialisation
just init                    # Première installation

# Gestion des services
just dev-up                  # Démarrer tous les services
just dev-down                # Arrêter tous les services
just dev-restart             # Redémarrer
just dev-status              # Voir le statut
just dev-logs                # Logs en temps réel
just dev-logs-service midpoint  # Logs d'un service spécifique

# Maintenance
just dev-reset               # Reset complet (supprime tout)
just dev-backup              # Backup des données
```

### Tests API SIRH

```powershell
# Tests unitaires
just test-onboard            # Créer un employé
just test-list               # Liste des employés
just test-stats              # Statistiques
just test-change EMP-0001    # Changement de poste
just test-offboard EMP-0001  # Offboarding

# Scénario complet
just test-scenario           # Cycle de vie complet automatisé
```

### Accès rapides

```powershell
just open-portal             # Ouvrir le portail
just open-midpoint           # Ouvrir MidPoint
just open-keycloak           # Ouvrir Keycloak
just open-grafana            # Ouvrir Grafana
just open-api                # Ouvrir la doc API SIRH
just open-all                # Ouvrir tous les services
```

### Base de données

```powershell
just db-psql                 # Console PostgreSQL
just db-backup               # Backup PostgreSQL
just db-restore backups/fichier.sql  # Restaurer
```

### Monitoring

```powershell
just health                  # Health check de tous les services
just metrics                 # Voir les métriques Prometheus
```

### Informations

```powershell
just --list                  # Liste toutes les commandes
just info                    # Informations du projet
```

## 🎬 Scénarios de démonstration

### 1. Cycle de vie automatisé complet

```powershell
# Lancer le scénario automatique
just test-scenario
```

### 2. Scénario manuel détaillé

```powershell
# 1. Onboarding
curl -X POST http://localhost:8000/employees/onboard `
  -H "Content-Type: application/json" `
  -d '{
    "first_name": "Marie",
    "last_name": "Dubois",
    "email": "marie.dubois@kerialis.fr",
    "department": "IT",
    "position": "Chef de projet",
    "start_date": "2024-12-17T09:00:00"
  }'

# 2. Vérifier dans MidPoint (aller à http://localhost:8080/midpoint)

# 3. Changement de département
curl -X POST http://localhost:8000/employees/EMP-0001/change `
  -H "Content-Type: application/json" `
  -d '{"new_department":"FINANCE","new_position":"Directeur financier"}'

# 4. Voir les métriques dans Grafana (http://localhost:3000)

# 5. Offboarding
curl -X POST http://localhost:8000/employees/EMP-0001/offboard
```

### 3. Monitoring dans Grafana

1. Accéder à http://localhost:3000
2. Login : `admin` / `admin123`
3. Naviguer vers "Dashboards" → "IAM 360° - Vue d'ensemble"
4. Observer les métriques en temps réel

## 📁 Structure du projet

```
IAM/
├── environments/
│   └── local/               # Environnement Docker local
│       ├── docker-compose.yml
│       ├── .env.example
│       └── nginx/
├── services/
│   ├── sirh-api/           # API Python FastAPI
│   ├── midpoint/           # Configurations MidPoint
│   ├── keycloak/           # Realms Keycloak
│   └── ldap/               # Schemas LDAP
├── monitoring/
│   ├── prometheus/         # Configuration Prometheus
│   └── grafana/            # Dashboards Grafana
├── scripts/
│   ├── local/              # Scripts PowerShell
│   └── cloud/              # Scripts déploiement cloud
├── infrastructure/
│   └── terraform/          # IaC pour Azure/AWS
├── docs/                   # Documentation
└── justfile                # Task runner
```

## 🔧 Configuration

### Variables d'environnement

Copier [environments/local/.env.example](environments/local/.env.example) vers `.env` et adapter :

```env
# MidPoint
MP_VER=4.8
MIDPOINT_ADMIN_PASSWORD=5ecr3t

# PostgreSQL
POSTGRES_PASSWORD=postgres2025

# Keycloak
KEYCLOAK_ADMIN_PASSWORD=admin123

# Vault
VAULT_ROOT_TOKEN=root-token-dev
```

### Personnalisation

- **MidPoint** : [services/midpoint/resources/](services/midpoint/resources/)
- **Keycloak** : [services/keycloak/realms/](services/keycloak/realms/)
- **LDAP** : [services/ldap/init/](services/ldap/init/)
- **Grafana** : [monitoring/grafana/dashboards/](monitoring/grafana/dashboards/)

## 🛠️ Dépannage

### Les services ne démarrent pas

```powershell
# Vérifier les ports occupés
netstat -ano | findstr "8080 8180 3000 5432"

# Vérifier Docker
docker ps
docker-compose -f environments/local/docker-compose.yml ps

# Voir les logs
just dev-logs
```

### MidPoint ne répond pas

```powershell
# MidPoint prend 2-3 minutes au démarrage
just dev-logs-service midpoint

# Vérifier la base de données
just dev-logs-service postgres
```

### Erreur de connexion PostgreSQL

```powershell
# Redémarrer PostgreSQL
cd environments/local
docker-compose restart postgres

# Vérifier le health
docker-compose ps
```

### Reset complet

```powershell
just dev-reset    # Tout supprimer et recommencer
just dev-up       # Redémarrer
```

## 📚 Documentation complète

- [Architecture détaillée](docs/architecture/README.md)
- [Guide de déploiement local](docs/guides/local-development.md)
- [Guide de déploiement production](docs/guides/production-deployment.md)
- [Opérations & Maintenance](docs/operations/)

## 🔒 Sécurité

⚠️ **Ce projet est un POC de démonstration**

En production :
- ✅ Utiliser des certificats SSL/TLS valides
- ✅ Changer **tous** les mots de passe par défaut
- ✅ Activer MFA sur tous les comptes admin
- ✅ Configurer les pare-feux et isolation réseau
- ✅ Implémenter la rotation automatique des secrets
- ✅ Activer l'audit complet
- ✅ Suivre le principe du moindre privilège
- ✅ Scanner les vulnérabilités régulièrement

## 🧪 Tests

```powershell
# Tests API SIRH
just test-scenario

# Tests d'intégration (à venir)
just test-integration

# Tests de charge (à venir)
just test-load
```

## 📈 Roadmap

- [x] Architecture de base
- [x] API SIRH avec provisioning
- [x] Monitoring Prometheus/Grafana
- [x] Documentation complète
- [ ] Tests d'intégration automatisés
- [ ] CI/CD Pipeline (GitHub Actions)
- [ ] Déploiement Kubernetes production
- [ ] MFA avancée (FIDO2, WebAuthn)
- [ ] Intégration Active Directory
- [ ] Workflows d'approbation avancés
- [ ] Audit & Compliance reporting

## 🤝 Contribution

Les contributions sont bienvenues ! Merci de :
1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📝 License

Ce projet est sous licence MIT. Voir [LICENSE](LICENSE) pour plus d'informations.

## 👥 Auteurs

**Kerialis** - IAM 360° Team

## 📞 Support

- 📧 Email: support@kerialis.fr
- 📖 Documentation: [docs/](docs/)
- 🐛 Issues: [GitHub Issues](https://github.com/votre-org/IAM/issues)

---

**Made with ❤️ by Kerialis** - *Identity Management Made Simple*
