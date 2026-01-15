#!/usr/bin/env just --justfile
# IAM 360° - Synchronisation MidPoint ↔ LDAP
# Linux only

set shell := ["bash", "-c"]

default:
    @just --list

# === INFRASTRUCTURE ===

# Démarrer les services
up:
    cd environments/local && docker-compose up -d
    @echo "✅ Services démarrés"
    @just status

# Arrêter les services
down:
    cd environments/local && docker-compose down
    @echo "✅ Services arrêtés"

# Redémarrer
restart:
    @just down
    @just up

# Statut services
status:
    @echo ""
    @echo "📊 Infrastructure Status:"
    cd environments/local && docker-compose ps
    @echo ""
    @echo "🔗 Access URLs:"
    @echo "   • MidPoint:     http://localhost:8080/midpoint (admin/5ecr3t)"
    @echo "   • Keycloak:     http://localhost:8180 (admin/changeme)"
    @echo "   • LDAP Admin:   http://localhost:8090"
    @echo "   • Grafana:      http://localhost:3000 (admin/admin)"
    @echo "   • Prometheus:   http://localhost:9090"
    @echo "   • SIRH API:     http://localhost:8000/docs"
    @echo ""

# Logs services
logs:
    cd environments/local && docker-compose logs -f

logs-service SERVICE:
    cd environments/local && docker-compose logs -f {{SERVICE}}

# === SIRH API ===

# Redémarrer API
api-restart:
    docker restart iam-sirh-api
    @echo "✅ SIRH API redémarrée"

# Logs API
api-logs:
    docker logs iam-sirh-api -f

# Voir audit logs
audit:
    docker exec iam-sirh-api cat audit.log | tail -20

# === OPERATIONS ===

# Créer un utilisateur de test
test-user EMAIL:
    @curl -s -X POST http://localhost:8000/onboard \
      -H "Content-Type: application/json" \
      -d '{"first_name":"Test","last_name":"User","email":"{{EMAIL}}","department":"IT","position":"Engineer"}' | jq .
    @echo "✅ User {{EMAIL}} créé avec sync MidPoint→LDAP"

# Lister utilisateurs
list-users:
    curl -s http://localhost:8000/employees | jq .

# Health check
health:
    curl -s http://localhost:8000/health | jq .

# === MAINTENANCE ===

# Nettoyer (rm volumes)
clean:
    cd environments/local && docker-compose down -v
    @echo "✅ All data cleaned"

# Reset complet
reset: clean
    @just up
    @echo "✅ System reset"

# === TESTS API SIRH ===

# Exécuter les tests unitaires de l'API SIRH
test-unit: