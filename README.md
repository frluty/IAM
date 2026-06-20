# pipeline-security

Pipeline CI/CD sécurité réutilisable pour GitHub Actions.

## Ce que fait ce pipeline

Pour chaque service (Python ou Node.js) :

1. **Détection du langage** — auto depuis les lockfiles
2. **Hardening Dockerfile** — Hadolint + contrôles ANSSI-PA-022
3. **Scan de code** — CodeQL (GHAS)
4. **Scan de dépendances** — Trivy FS sur les lockfiles
5. **Build & Push image** — GHCR, ACR ou Harbor
6. **Scan d'image** — Trivy CVE + Dockle CIS benchmark
7. **Signature** — Cosign (keyless Sigstore ou keypair)

## Utilisation dans un repo projet

Copier un template depuis [`templates/`](templates/) dans `.github/workflows/ci.yml` :

```yaml
jobs:
  pipeline:
    uses: frluty/pipeline-security/.github/workflows/reusable-security.yml@main
    permissions:
      actions:         read
      contents:        read
      packages:        write
      security-events: write
      id-token:        write
      attestations:    write
    with:
      language:       python        # ou node
      app_path:       services/mon-service
      image_name:     mon-service
      dockerfile:     services/mon-service/Dockerfile
      context:        services/mon-service
      registry_type:  ghcr
      enable_signing: ${{ github.event_name != 'pull_request' }}
```

## Paramètres

| Paramètre | Défaut | Description |
|-----------|--------|-------------|
| `language` | `auto` | `python` \| `node` \| `auto` |
| `app_path` | `.` | Répertoire source |
| `image_name` | — | Nom de l'image (kebab-case, **requis**) |
| `dockerfile` | `Dockerfile` | Chemin Dockerfile |
| `context` | `.` | Contexte de build |
| `registry_type` | — | `ghcr` \| `acr` \| `harbor` (**requis**) |
| `registry_url` | `""` | Hostname du registre (ACR/Harbor) |
| `enable_signing` | `true` | Activer la signature Cosign |
| `signing_mode` | `keyless` | `keyless` \| `keypair` |
| `severity` | `CRITICAL,HIGH` | Sévérité Trivy |
| `fail_on_vulnerability` | `true` | Bloquer sur CVE |

## Secrets requis selon le registry

| Registry | Secrets |
|----------|---------|
| GHCR | aucun (GITHUB_TOKEN natif) |
| ACR — Service Principal | `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_TENANT_ID` |
| ACR — Workload Identity | `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` |
| Harbor | `HARBOR_USERNAME`, `HARBOR_PASSWORD` |
| Cosign keypair | `COSIGN_PRIVATE_KEY`, `COSIGN_PASSWORD` |
