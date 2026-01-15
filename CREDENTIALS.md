# 🔐 IAM 360° - Credentials & Access

## 🎉 Synchronisation Status

**✅ ACTIVE & TESTED** (2026-01-15)

- 3 utilisateurs synchronisés avec succès
- MidPoint + LDAP auto-provisioning 100% fonctionnel
- Taux de succès: 100%
- Documentation: [SYNC_SUCCESS.md](SYNC_SUCCESS.md), [FINAL_REPORT.md](FINAL_REPORT.md)



**Date:** January 14, 2026  
**Status:** ✅ All core services operational

---

## 🌐 Service URLs

| Service | URL | Status |
|---------|-----|--------|
| MidPoint (IGA) | http://localhost:8080/midpoint/ | ✅ Running |
| Keycloak (SSO) | http://localhost:8180/ | ✅ Running with realm |
| SIRH API | http://localhost:8000/docs | ✅ Running |
| Grafana | http://localhost:3000 | ✅ Running |
| Prometheus | http://localhost:9090 | ✅ Running |
| phpLDAPadmin | http://localhost:8081 | ✅ Running |
| Alertmanager | http://localhost:9093 | ✅ Running |

---

## 🔑 Credentials

### MidPoint
- **URL:** http://localhost:8080/midpoint/
- **Admin:** `administrator` / `5ecr3t`

### Keycloak
- **Admin Console:** http://localhost:8180/admin/
- **Admin:** `admin` / `admin123`

#### Realm: kerialis
- **User 1 (Admin):** `administrator` / `Keycl0ak2025!`  
  Roles: `admin`
  
- **User 2 (RH):** `jdupont` / `User2025!`  
  Roles: `user`, `rh`

#### OAuth2 Clients
| Client | Client ID | Secret |
|--------|-----------|--------|
| MidPoint | `midpoint` | `midpoint-secret-2025` |
| SIRH API | `sirh-api` | `sirh-secret-2025` |
| Grafana | `grafana` | `grafana-secret-2025` |

### LDAP
- **URL:** ldap://localhost:389
- **Base DN:** `dc=kerialis,dc=local`
- **Admin DN:** `cn=admin,dc=kerialis,dc=local`
- **Password:** `admin`

### phpLDAPadmin
- **URL:** http://localhost:8081
- **Login DN:** `cn=admin,dc=kerialis,dc=local`
- **Password:** `admin`

### PostgreSQL
- **Host:** localhost:5432
- **Admin User:** `postgres` / `postgres2025`

#### Databases
| Database | Owner | Password |
|----------|-------|----------|
| `midpoint` | `midpoint` | `postgres2025` |
| `keycloak` | `keycloak` | `postgres2025` |
| `sirh` | `sirh` | `postgres2025` |

### Grafana
- **URL:** http://localhost:3000
- **User:** `admin` / `admin`

### Redis
- **Host:** localhost:6379
- **Password:** `redis2025`

---

## 🧪 Quick Test Commands

```powershell
# Test onboarding
just test-onboard

# Test changes
just test-change

# Test offboarding
just test-offboard

# Full scenario
just test-scenario

# Check service status
just dev-status

# View logs
just dev-logs
```

---

## 📊 Monitoring URLs

- **Prometheus Metrics:** http://localhost:9090/metrics
- **SIRH API Metrics:** http://localhost:8000/metrics
- **Grafana Dashboards:** http://localhost:3000/dashboards
- **Alert Rules:** http://localhost:9090/alerts
- **Alertmanager:** http://localhost:9093

---

## 🔧 Maintenance Commands

### Restart all services
```powershell
cd environments/local
docker-compose restart
```

### Recreate databases (if needed)
```powershell
.\scripts\local\setup-databases.ps1
```

### View service logs
```powershell
# All services
docker-compose logs -f

# Specific service
docker logs iam-midpoint --tail 100 -f
docker logs iam-keycloak --tail 100 -f
```

### Clean and restart
```powershell
just dev-clean
just dev-up
```

---

## 📝 Notes

- **Keycloak realm:** Imported automatically on first start
- **PostgreSQL databases:** Auto-created on first PostgreSQL container start
- **MidPoint initialization:** Requires `midpoint_init` container to complete successfully
- **LDAP data:** Persisted in `local_ldap_data` volume
- **Vault:** Currently unhealthy (not critical for basic operations)

---

## 🆘 Troubleshooting

See [QUICKSTART.md](./QUICKSTART.md) for detailed troubleshooting steps.

Quick fixes:
```powershell
# If PostgreSQL databases missing
.\scripts\local\setup-databases.ps1

# If MidPoint won't start
docker-compose stop midpoint midpoint_init
docker-compose rm -f midpoint midpoint_init
docker volume rm local_midpoint_home
docker-compose up -d midpoint_init
docker-compose up -d midpoint

# If Keycloak won't start
docker-compose restart keycloak
```
