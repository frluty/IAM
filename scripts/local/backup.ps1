# Script de backup des données IAM 360°

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupDir = "backups\$timestamp"

Write-Host "💾 Backup du projet IAM 360°" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""

# Création du dossier de backup
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Write-Host "📁 Dossier de backup: $backupDir" -ForegroundColor Yellow
Write-Host ""

Push-Location "environments\local"

try {
    # Backup PostgreSQL
    Write-Host "🐘 Backup PostgreSQL..." -ForegroundColor Yellow
    
    docker-compose exec -T postgres pg_dumpall -U postgres > "..\..\$backupDir\postgres-dump.sql"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ PostgreSQL sauvegardé" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Erreur backup PostgreSQL" -ForegroundColor Red
    }

    # Backup LDAP
    Write-Host "📁 Backup LDAP..." -ForegroundColor Yellow
    docker-compose exec -T ldap slapcat -n 0 > "..\..\$backupDir\ldap-config.ldif"
    docker-compose exec -T ldap slapcat -n 1 > "..\..\$backupDir\ldap-data.ldif"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ LDAP sauvegardé" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Erreur backup LDAP" -ForegroundColor Red
    }

    # Backup configurations
    Write-Host "⚙️  Backup configurations..." -ForegroundColor Yellow
    Copy-Item ".env" "..\..\$backupDir\.env" -ErrorAction SilentlyContinue
    Copy-Item "..\..\services" "..\..\$backupDir\services" -Recurse -ErrorAction SilentlyContinue
    Write-Host "✅ Configurations sauvegardées" -ForegroundColor Green

    # Compression (optionnel)
    Write-Host ""
    $compress = Read-Host "Compresser le backup? (oui/non)"
    if ($compress -eq "oui") {
        $zipPath = "backups\iam-backup-$timestamp.zip"
        Compress-Archive -Path $backupDir -DestinationPath $zipPath
        Write-Host "✅ Backup compressé: $zipPath" -ForegroundColor Green
        
        $deleteOriginal = Read-Host "Supprimer le dossier non compressé? (oui/non)"
        if ($deleteOriginal -eq "oui") {
            Remove-Item $backupDir -Recurse -Force
        }
    }

    Write-Host ""
    Write-Host "✅ Backup terminé !" -ForegroundColor Green

} catch {
    Write-Host "❌ Erreur: $_" -ForegroundColor Red
} finally {
    Pop-Location
}
