# Script de reset complet du projet IAM 360°
# Arrête et supprime tous les conteneurs, volumes et réseaux

Write-Host "🔄 Reset complet du projet IAM 360°" -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Yellow
Write-Host ""

$confirmation = Read-Host "⚠️  Cela va supprimer TOUTES les données. Continuer? (oui/non)"

if ($confirmation -ne "oui") {
    Write-Host "Annulé." -ForegroundColor Red
    exit 0
}

Write-Host ""
Write-Host "🛑 Arrêt des services..." -ForegroundColor Yellow

Push-Location "environments\local"

try {
    # Arrêt et suppression des conteneurs
    docker-compose down

    # Suppression des volumes
    Write-Host ""
    Write-Host "🗑️  Suppression des volumes..." -ForegroundColor Yellow
    docker-compose down -v

    # Nettoyage des images non utilisées (optionnel)
    Write-Host ""
    $cleanImages = Read-Host "Nettoyer aussi les images inutilisées? (oui/non)"
    if ($cleanImages -eq "oui") {
        docker image prune -f
        Write-Host "✅ Images nettoyées" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "✅ Reset terminé !" -ForegroundColor Green
    Write-Host ""
    Write-Host "Pour redémarrer: just dev-up" -ForegroundColor Cyan

} catch {
    Write-Host "❌ Erreur: $_" -ForegroundColor Red
} finally {
    Pop-Location
}
