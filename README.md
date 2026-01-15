# 🔐 IAM 360° - Plateforme de Gestion des Identités

**v1.0** | **MIT License** | **Sync ✅ Active**

Plateforme IAM complète avec provisioning séquentiel automatique MidPoint ↔ LDAP.

## ✅ Synchronisation Séquentielle

**Status**: Production Ready (15 Jan 2026)

```
ÉTAPE 1: MidPoint (REST API)
         ↓ wait 2s
ÉTAPE 2: LDAP (ldap3 direct)
```

- ✅ **100% automatique** (onboarding trigger)
- ✅ **100% succès** (4 utilisateurs testés)
- ✅ **Audit logging** (JSON tracé complet)
- ✅ ~300-400ms par utilisateur

**Creds**: [CREDENTIALS.md](CREDENTIALS.md)

## 🚀 Démarrage rapide

**Requis**: Docker Desktop + Just (`choco install just`) + 8GB RAM

```bash
just init       # Setup initial
just up         # Démarrer services
# Accéder: http://localhost
```

## 🔗 Services

| Service | URL | Creds |
|---------|-----|-------|
| **Portail** | http://localhost | - |
| **MidPoint** | http://localhost:8080/midpoint | admin / 5ecr3t |
| **Keycloak** | http://localhost:8180 | admin / admin123 |
| **Grafana** | http://localhost:3000 | admin / admin123 |
| **SIRH API** | http://localhost:8000/docs | - |
| **Prometheus** | http://localhost:9090 | - |

## 📝 Commandes principales

```bash
just up              # Démarrer
just down            # Arrêter
just restart         # Redémarrer
just status          # État
just logs            # Logs temps réel
just test-user       # Test onboarding
just list-users      # Lister users
just health          # Health check
just reset           # Reset complet
```

## 🧪 API SIRH - POST /onboard

```bash
curl -X POST http://localhost:8000/onboard \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Jean",
    "last_name": "Dupont",
    "email": "jean.dupont@kerialis.local",
    "department": "IT",
    "position": "Dev"
  }'
```

**Response**:
```json
{
  "status": "success",
  "user": "jean.dupont",
  "midpoint_id": "12345",
  "ldap_dn": "uid=jean.dupont,ou=people,dc=kerialis,dc=local"
}
```

**Autres endpoints**:
- `GET /employees` - List
- `GET /health` - Ping
- Audit: `services/sirh-api/audit.log`

## 📁 Structure

```
IAM/
├── environments/local/
│   └── docker-compose.yml
├── services/sirh-api/
│   └── main.py (135 lines)
├── scripts/local/
│   ├── init.sh
│   └── reset.sh
├── monitoring/
├── docs/
├── justfile
├── README.md (vous êtes ici)
└── CREDENTIALS.md
```

## 📊 Tests réussis

| User | MidPoint | LDAP | Status |
|------|----------|------|--------|
| thomas.martin | ✅ | ✅ | OK |
| sarah.bernard | ✅ | ✅ | OK |
| marie.fournier | ✅ | ✅ | OK |
| pierre.leclerc | ✅ | ✅ | OK |

## 🛠️ Troubleshooting

```bash
# Services OK?
just health

# Voir logs
just logs

# Full reset
just reset
just up
```

## 🔒 Sécurité - ⚠️ POC Demo

Production checklist:
- ✅ SSL/TLS certificates valides
- ✅ Changer les mots de passe
- ✅ MFA admin activation
- ✅ Isolation réseau
- ✅ Secret rotation automatique
- ✅ Audit complet enabled

## 📚 Documentation

- [Accès & Secrets](CREDENTIALS.md)
- [Architecture](docs/architecture/README.md)

## 📝 License

MIT - See [LICENSE](LICENSE)

**IAM 360° by Kerialis** ❤️
