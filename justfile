# Justfile pour IAM 360° - Windows + Docker Desktop
# Utilise PowerShell par défaut

set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]
set dotenv-load := true

# Liste toutes les recettes disponibles
default:
    @just --list

# === DÉVELOPPEMENT LOCAL (Docker Compose) ===

# Initialiser le projet (première utilisation)
init:
    @Write-Host "🚀 Initialisation du projet IAM 360°..." -ForegroundColor Cyan
    @pwsh -File scripts/local/init.ps1

# Démarrer tous les services en local
dev-up:
    @Write-Host "🚀 Démarrage des services IAM..." -ForegroundColor Cyan
    @cd environments/local && docker-compose up -d
    @Write-Host ""
    @Write-Host "✅ Services démarrés !" -ForegroundColor Green
    @Write-Host "📊 Portail: " -NoNewline -ForegroundColor Cyan
    @Write-Host "http://localhost" -ForegroundColor Yellow
    @Write-Host "⏳ Attendre 2-3 minutes pour l'initialisation complète" -ForegroundColor Yellow
    @just dev-status

# Arrêter tous les services
dev-down:
    @Write-Host "🛑 Arrêt des services..." -ForegroundColor Yellow
    @cd environments/local && docker-compose down
    @Write-Host "✅ Services arrêtés" -ForegroundColor Green

# Redémarrer tous les services
dev-restart:
    @just dev-down
    @just dev-up

# Voir les logs de tous les services
dev-logs:
    @cd environments/local && docker-compose logs -f

# Voir les logs d'un service spécifique
dev-logs-service SERVICE:
    @cd environments/local && docker-compose logs -f {{SERVICE}}

# Statut des services
dev-status:
    @Write-Host ""
    @Write-Host "📊 Statut des services:" -ForegroundColor Cyan
    @cd environments/local && docker-compose ps

# Rebuild d'un service spécifique
dev-rebuild SERVICE:
    @Write-Host "🔨 Rebuild de {{SERVICE}}..." -ForegroundColor Yellow
    @cd environments/local && docker-compose up -d --build {{SERVICE}}

# Reset complet (supprime tout)
dev-reset:
    @pwsh -File scripts/local/reset.ps1

# Backup des données
dev-backup:
    @pwsh -File scripts/local/backup.ps1

# === TESTS API SIRH ===

# Onboarding d'un employé test
test-onboard:
    @Write-Host "➕ Test Onboarding..." -ForegroundColor Cyan
    @curl -X POST http://localhost:8000/employees/onboard `
        -H "Content-Type: application/json" `
        -d '{\"first_name\":\"Jean\",\"last_name\":\"Durand\",\"email\":\"jean.durand@kerialis.fr\",\"department\":\"IT\",\"position\":\"Développeur\",\"start_date\":\"2024-12-17T09:00:00\"}'

# Liste des employés
test-list:
    @Write-Host "📋 Liste des employés:" -ForegroundColor Cyan
    @curl -s http://localhost:8000/employees | ConvertFrom-Json | ConvertTo-Json -Depth 10

# Statistiques
test-stats:
    @Write-Host "📊 Statistiques:" -ForegroundColor Cyan
    @curl -s http://localhost:8000/stats | ConvertFrom-Json | ConvertTo-Json

# Changement de poste
test-change ID:
    @Write-Host "🔄 Test Changement..." -ForegroundColor Cyan
    @curl -X POST http://localhost:8000/employees/{{ID}}/change `
        -H "Content-Type: application/json" `
        -d '{\"new_department\":\"FINANCE\",\"new_position\":\"Manager\"}'

# Offboarding
test-offboard ID:
    @Write-Host "➖ Test Offboarding..." -ForegroundColor Cyan
    @curl -X POST http://localhost:8000/employees/{{ID}}/offboard

# Scénario complet
test-scenario:
    @Write-Host "🎬 Exécution du scénario complet..." -ForegroundColor Cyan
    @Write-Host ""
    @Write-Host "1️⃣  Onboarding Alice Martin..." -ForegroundColor Yellow
    @curl -X POST http://localhost:8000/employees/onboard `
        -H "Content-Type: application/json" `
        -d '{\"first_name\":\"Alice\",\"last_name\":\"Martin\",\"email\":\"alice.martin@kerialis.fr\",\"department\":\"IT\",\"position\":\"DevOps\",\"start_date\":\"2024-12-17T09:00:00\"}'
    @Write-Host ""
    @Start-Sleep -Seconds 2
    @Write-Host "2️⃣  Changement de département..." -ForegroundColor Yellow
    @curl -X POST http://localhost:8000/employees/EMP-0001/change `
        -H "Content-Type: application/json" `
        -d '{\"new_department\":\"SALES\",\"new_position\":\"Sales Manager\"}'
    @Write-Host ""
    @Start-Sleep -Seconds 2
    @Write-Host "3️⃣  Statistiques finales:" -ForegroundColor Yellow
    @curl -s http://localhost:8000/stats | ConvertFrom-Json | ConvertTo-Json
    @Write-Host ""
    @Write-Host "✅ Scénario terminé !" -ForegroundColor Green

# === ACCÈS RAPIDES ===

# Ouvrir MidPoint
open-midpoint:
    @Start-Process "http://localhost:8080/midpoint"

# Ouvrir Keycloak
open-keycloak:
    @Start-Process "http://localhost:8180"

# Ouvrir Grafana
open-grafana:
    @Start-Process "http://localhost:3000"

# Ouvrir API SIRH docs
open-api:
    @Start-Process "http://localhost:8000/docs"

# Ouvrir le portail
open-portal:
    @Start-Process "http://localhost"

# Ouvrir tous les services
open-all:
    @just open-portal
    @Start-Sleep -Milliseconds 500
    @just open-midpoint
    @Start-Sleep -Milliseconds 500
    @just open-keycloak
    @Start-Sleep -Milliseconds 500
    @just open-grafana
    @Start-Sleep -Milliseconds 500
    @just open-api

# === BASE DE DONNÉES ===

# Accès psql PostgreSQL
db-psql:
    @cd environments/local && docker-compose exec postgres psql -U postgres

# Backup PostgreSQL
db-backup:
    @$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"; `
    New-Item -ItemType Directory -Path "backups" -Force | Out-Null; `
    cd environments/local && docker-compose exec -T postgres pg_dumpall -U postgres > "../../backups/postgres-$timestamp.sql"; `
    Write-Host "✅ Backup: backups/postgres-$timestamp.sql" -ForegroundColor Green

# Restore PostgreSQL
db-restore FILE:
    @cd environments/local && cat ../../{{FILE}} | docker-compose exec -T postgres psql -U postgres

# === MONITORING ===

# Voir les métriques Prometheus
metrics:
    @curl -s http://localhost:9090/api/v1/query?query=up | ConvertFrom-Json | ConvertTo-Json -Depth 10

# Health check de tous les services
health:
    @Write-Host "🏥 Health Check:" -ForegroundColor Cyan
    @Write-Host ""
    @Write-Host "SIRH API:  " -NoNewline
    @try { $r = curl -s http://localhost:8000/health | ConvertFrom-Json; Write-Host $r.status -ForegroundColor Green } catch { Write-Host "❌ DOWN" -ForegroundColor Red }
    @Write-Host "MidPoint:  " -NoNewline
    @try { curl -s http://localhost:8080/midpoint/ | Out-Null; Write-Host "✅ UP" -ForegroundColor Green } catch { Write-Host "❌ DOWN" -ForegroundColor Red }
    @Write-Host "Keycloak:  " -NoNewline
    @try { curl -s http://localhost:8180/ | Out-Null; Write-Host "✅ UP" -ForegroundColor Green } catch { Write-Host "❌ DOWN" -ForegroundColor Red }
    @Write-Host "Grafana:   " -NoNewline
    @try { curl -s http://localhost:3000/ | Out-Null; Write-Host "✅ UP" -ForegroundColor Green } catch { Write-Host "❌ DOWN" -ForegroundColor Red }

# === NETTOYAGE ===

# Nettoyer les images Docker non utilisées
clean-images:
    @docker image prune -f

# Nettoyer les volumes non utilisés
clean-volumes:
    @docker volume prune -f

# Nettoyage complet Docker
clean-all:
    @docker system prune -af --volumes

# === CLOUD (TERRAFORM) ===

# Plan Terraform
cloud-plan ENV:
    @cd infrastructure/terraform/environments/{{ENV}} && terraform plan

# Apply Terraform
cloud-apply ENV:
    @cd infrastructure/terraform/environments/{{ENV}} && terraform apply

# Destroy Terraform
cloud-destroy ENV:
    @cd infrastructure/terraform/environments/{{ENV}} && terraform destroy

# === DOCUMENTATION ===

# Afficher les informations du projet
info:
    @Write-Host ""
    @Write-Host "🔐 IAM 360° - Kerialis" -ForegroundColor Cyan
    @Write-Host "=====================" -ForegroundColor Cyan
    @Write-Host ""
    @Write-Host "📊 Services disponibles:" -ForegroundColor Yellow
    @Write-Host "  • MidPoint (IGA):     http://localhost:8080/midpoint" -ForegroundColor White
    @Write-Host "  • Keycloak (SSO):     http://localhost:8180" -ForegroundColor White
    @Write-Host "  • Grafana:            http://localhost:3000" -ForegroundColor White
    @Write-Host "  • SIRH API:           http://localhost:8000/docs" -ForegroundColor White
    @Write-Host "  • Vault:              http://localhost:8200" -ForegroundColor White
    @Write-Host "  • phpLDAPadmin:       http://localhost:8090" -ForegroundColor White
    @Write-Host "  • Prometheus:         http://localhost:9090" -ForegroundColor White
    @Write-Host "  • Portail:            http://localhost" -ForegroundColor White
    @Write-Host ""
    @Write-Host "🔑 Identifiants par défaut:" -ForegroundColor Yellow
    @Write-Host "  • MidPoint:    admin / 5ecr3t" -ForegroundColor White
    @Write-Host "  • Keycloak:    admin / admin123" -ForegroundColor White
    @Write-Host "  • Grafana:     admin / admin123" -ForegroundColor White
    @Write-Host "  • Vault:       root-token-dev" -ForegroundColor White
    @Write-Host ""
    @Write-Host "📖 Commandes utiles:" -ForegroundColor Yellow
    @Write-Host "  just init          - Initialiser le projet" -ForegroundColor White
    @Write-Host "  just dev-up        - Démarrer les services" -ForegroundColor White
    @Write-Host "  just dev-logs      - Voir les logs" -ForegroundColor White
    @Write-Host "  just test-scenario - Exécuter un scénario test" -ForegroundColor White
    @Write-Host "  just open-all      - Ouvrir tous les services" -ForegroundColor White
    @Write-Host "  just health        - Health check" -ForegroundColor White
    @Write-Host ""