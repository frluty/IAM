# Security Pipeline — Docker Build, Scan & Sign

Pipeline GitHub Actions réutilisable couvrant l'ensemble du cycle de sécurité d'une image Docker.

## Architecture du pipeline

```
push / PR
    │
    ▼
┌─────────────────┐       Trivy FS (vuln + secret + misconfig)
│  1. Code Scan   │  ──▶  Semgrep (OWASP, secrets, default rules)
└────────┬────────┘       → Résultats dans l'onglet Security (SARIF)
         │ success
         ▼
┌─────────────────┐       docker buildx (multi-arch)
│  2. Build &     │  ──▶  docker/metadata-action (tags auto)
│     Push        │       SBOM + provenance générés (BuildKit)
└────────┬────────┘       GitHub artifact attestation
         │
         ▼
┌─────────────────┐       Trivy image scan (post-push)
│  3. Image Scan  │  ──▶  Résultats SARIF + rapport JSON artifact
└────────┬────────┘       Échec configurable selon sévérité
         │ success
         ▼
┌─────────────────┐       cosign sign (keyless OIDC ou key-pair)
│  4. Sign Image  │  ──▶  attestation de build metadata
└─────────────────┘       vérification automatique post-signature
```

## Registries supportés

| Type | Description | Auth |
|------|-------------|------|
| `ghcr` | GitHub Container Registry | `GITHUB_TOKEN` automatique |
| `acr`  | Azure Container Registry | Service Principal **ou** Workload Identity (OIDC) |
| `harbor` | Harbor on-premise | Username / Password |

## Inputs du workflow réutilisable

### Image

| Input | Défaut | Description |
|-------|--------|-------------|
| `image_name` | — | **Requis.** Nom de l'image (ex: `sirh-api`) |
| `dockerfile` | `Dockerfile` | Chemin vers le Dockerfile |
| `context` | `.` | Contexte de build Docker |
| `build_args` | — | ARG Docker (multiline `KEY=VALUE`) |
| `platforms` | `linux/amd64` | Plateformes cibles (ex: `linux/amd64,linux/arm64`) |

### Registry

| Input | Défaut | Description |
|-------|--------|-------------|
| `registry_type` | — | **Requis.** `ghcr` \| `acr` \| `harbor` |
| `registry_url` | — | Hostname du registre (requis pour `acr` et `harbor`) |
| `registry_namespace` | — | Namespace/projet dans le registre |
| `extra_tags` | — | Tags additionnels séparés par virgule |

### Contrôle du pipeline

| Input | Défaut | Description |
|-------|--------|-------------|
| `enable_code_scan` | `true` | Activer le scan code/secrets |
| `enable_image_scan` | `true` | Activer le scan d'image |
| `enable_signing` | `true` | Activer la signature Cosign |
| `signing_mode` | `keyless` | `keyless` (OIDC Sigstore) ou `keypair` |
| `scan_severity` | `CRITICAL,HIGH` | Niveaux déclenchant un échec |
| `fail_on_vulnerability` | `true` | Bloquer si vulnérabilités détectées |

## Secrets requis selon le registry

### GHCR
Aucun secret additionnel — le `GITHUB_TOKEN` est utilisé automatiquement.

### ACR — Service Principal
```
AZURE_CLIENT_ID      → App Registration App ID
AZURE_CLIENT_SECRET  → Client secret
AZURE_TENANT_ID      → ID du tenant Azure
```

### ACR — Workload Identity Federation (recommandé, sans secret)
```
AZURE_CLIENT_ID       → App Registration App ID
AZURE_TENANT_ID       → ID du tenant Azure
AZURE_SUBSCRIPTION_ID → ID de la souscription
```
Configurer la federated credential sur l'App Registration :
- Issuer : `https://token.actions.githubusercontent.com`
- Subject : `repo:<org>/<repo>:ref:refs/heads/main`

### Harbor
```
REGISTRY_USERNAME → Utilisateur Harbor
REGISTRY_PASSWORD → Mot de passe / token Harbor
```

## Signature Cosign

### Mode keyless (recommandé)
Aucun secret requis. La signature utilise l'identité OIDC GitHub Actions via Sigstore/Rekor (log de transparence public).

```bash
# Vérification manuelle
cosign verify \
  --certificate-identity-regexp "https://github.com/<org>/<repo>/" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  ghcr.io/<org>/sirh-api@sha256:<digest>
```

### Mode keypair
1. Lancer le workflow utilitaire `[Utility] Generate Cosign Key Pair`
2. Copier la clé privée dans le secret `COSIGN_PRIVATE_KEY`
3. Définir `COSIGN_PASSWORD` (passphrase)
4. Conserver `cosign.pub` pour la vérification

```bash
# Vérification manuelle
cosign verify --key cosign.pub ghcr.io/<org>/sirh-api@sha256:<digest>
```

## Utilisation — exemple minimal

```yaml
jobs:
  pipeline:
    uses: ./.github/workflows/reusable-docker-security.yml
    permissions:
      contents: read
      packages: write
      security-events: write
      id-token: write
      attestations: write
    with:
      image_name:   mon-service
      dockerfile:   services/mon-service/Dockerfile
      context:      services/mon-service
      registry_type: ghcr
      enable_signing: true
      signing_mode:   keyless
```

## Sorties du workflow

| Output | Description |
|--------|-------------|
| `image_digest` | SHA256 digest de l'image (`sha256:abc123...`) |
| `image_uri` | URI complète `registry/image@sha256:...` |
| `image_tags` | Liste des tags appliqués |

## Ignorer des CVE

Éditer `.trivyignore` à la racine du dépôt :
```
# CVE-2023-XXXX  # raison + ticket de suivi
```
