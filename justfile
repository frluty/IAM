# justfile
set dotenv-load := true

# Lancement local ultra-rapide (Docker Desktop)
local:
    #!/usr/bin/env bash
    echo "Lancement IAM 360° en local (Docker Desktop)..."
    docker compose -f platform/manifests-local/docker-compose.yml up -d
    echo "MidPoint → https://localhost"
    echo "Keycloak → https://localhost:8443"
    echo "Vault → https://localhost:8200/ui"
    echo "Wazuh → https://localhost:5601"
    echo "n8n → http://localhost:5678"
    echo "Grafana → http://localhost:3000"

# Arrêt propre
stop:
    docker compose -f platform/manifests-local/docker-compose.yml down -v

# Passage en mode Azure AKS (prod)
deploy env:
    #!/usr/bin/env bash
    cd infra
    terraform init -backend-config=../environments/{{env}}/backend.hcl
    terraform workspace select {{env}} || terraform workspace new {{env}}
    terraform apply -var-file=../environments/{{env}}/terraform.tfvars -auto-approve

# Exemple : juste taper → just deploy prod
# Ou → just deploy staging

# Test complet (lint + security + tests MidPoint)
test:
    terraform fmt -check
    terraform validate
    tflint
    checkov -d .
    echo "Tests MidPoint simulés (à venir avec Robot Framework)"

# Switch rapide de contexte kube (local ↔ Azure)
context ctx:
    #!/usr/bin/env bash
    if [ "{{ctx}}" = "local" ]; then
      kubectl config use-context docker-desktop
      echo "Contexte → Docker Desktop (local)"
    else
      az aks get-credentials --resource-group rg-iam-{{ctx}} --name aks-iam-{{ctx}} --overwrite-existing
      kubectl config use-context aks-iam-{{ctx}}
      echo "Contexte → AKS {{ctx}}"
    fi