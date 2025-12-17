#!/bin/bash
# Script de reset complet

echo "🔄 Reset complet du projet IAM 360°"
echo "===================================="
echo ""

read -p "⚠️  Cela va supprimer TOUTES les données. Continuer? (oui/non): " confirmation

if [ "$confirmation" != "oui" ]; then
    echo "Annulé."
    exit 0
fi

echo ""
echo "🛑 Arrêt des services..."
cd environments/local

# Arrêt et suppression
docker-compose down

# Suppression des volumes
echo ""
echo "🗑️  Suppression des volumes..."
docker-compose down -v

# Nettoyage images
echo ""
read -p "Nettoyer aussi les images inutilisées? (oui/non): " clean_images
if [ "$clean_images" = "oui" ]; then
    docker image prune -f
    echo "✅ Images nettoyées"
fi

echo ""
echo "✅ Reset terminé !"
echo ""
echo "Pour redémarrer: just dev-up"
