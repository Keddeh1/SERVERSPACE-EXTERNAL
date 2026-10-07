# SERVERSPACE-EXTERNAL — Unified Dual-Family Runtime Bundle

This is the external-facing production instance of the unified KEDDEH runtime.

**Twin Repository:** [Keddeh1/SERVERSPACE](https://github.com/Keddeh1/SERVERSPACE) (internal codex branch)

## Dual-Family Architecture

Both repositories share a **single bundled runtime** that deploys as **two separate operational families**:

### Family 1: Internal (SERVERSPACE/codex)
- **Branch:** `codex`
- **Mode:** Development, staging, and internal operations
- **Access:** Private development and testing
- **DNS:** Internal resolver
- **Sync direction:** Source of truth

### Family 2: External (SERVERSPACE-EXTERNAL/production)
- **Branch:** `production`
- **Mode:** Public-facing, customer-facing, external services
- **Access:** Public internet-exposed runtime
- **DNS:** Public resolver (KEDDEH.COM)
- **Sync direction:** Pulled from internal via sibling assimilation

## Sibling Assimilation Model

Both families run from the same runtime bundle but operate independently:

1. **Internal codex branch** develops and tests all runtime logic
2. **External production branch** pulls validated code from codex
3. Each family runs its own isolated runtime instance
4. Configuration files determine which family (internal/external) is active
5. DNS and web services differ between families but use identical core runtime

## Bundle Structure

```
shared-runtime-bundle/
  ├── runtime/
  │   ├── bootstrap.sh          # Universal bootstrap
  │   ├── family-config.json     # Family selector
  │   ├── internal.config.json   # Internal family settings
  │   ├── external.config.json   # External family settings
  │   ├─┠ core/                 # Shared runtime core
  │   ├─┠ dns/                  # DNS modules
  │   └─┠ services/             # Service definitions
  ├┠ sites/                 # Web content
  ├┠ packages/              # HTML packages
  └─┠ .github/workflows/     # CI/CD for dual sync
```

## Launch as Two Families

**Internal Family (SERVERSPACE/codex):**
```bash
env FAMILY=internal ./runtime/bootstrap.sh
```

**External Family (SERVERSPACE-EXTERNAL/production):**
```bash
env FAMILY=external ./runtime/bootstrap.sh
```

Both run the same core runtime but with different DNS zones, web roots, and external-facing configuration.

## Sibling Sync Workflow

1. Changes committed to `SERVERSPACE/codex`
2. CI/CD validates and tests internal family
3. When ready, codex is merged/pushed to `SERVERSPACE-EXTERNAL/production`
4. External family automatically deploys from production branch
5. Both families stay synchronized without manual intervention

## DNS & Public Services

**Internal DNS (SERVERSPACE/codex):**
- Internal zone files: `runtime/dns/internal/`
- Private resolver: `resolver-internal.html`
- Accessible only to internal network

**External DNS (SERVERSPACE-EXTERNAL/production):**
- Public zone files: `runtime/dns/external/`
- Public resolver: `resolver-external.html` (served as KEDDEH.COM)
- Accessible from public internet

## Configuration Inheritance

Each family inherits the core runtime but uses distinct configuration:

```json
// Family config selector
{
  "family": "external",
  "inherits_from": "internal",
  "environment": "production",
  "public_facing": true,
  "dns_zones": "runtime/dns/external/",
  "site_root": "sites/keddeh.com/public"
}
```

## Getting Started

### Clone both repos (or one if using as template)

```bash
# Internal development
git clone https://github.com/Keddeh1/SERVERSPACE.git
cd SERVERSPACE
git checkout codex

# External production
git clone https://github.com/Keddeh1/SERVERSPACE-EXTERNAL.git
cd SERVERSPACE-EXTERNAL
git checkout production
```

### Launch internal family

```bash
cd SERVERSPACE
env FAMILY=internal ./runtime/bootstrap.sh
```

### Launch external family

```bash
cd SERVERSPACE-EXTERNAL
env FAMILY=external ./runtime/bootstrap.sh
```

## Advantages

✓ **Single codebase, two deployments** — No duplication of core logic  
✓ **Staged rollout** — Internal testing before external production  
✓ **Atomic sync** — Both families can update together or independently  
✓ **Sibling assimilation** — Changes automatically flow from internal to external  
✓ **Isolated operation** — Each family runs independently once deployed  
✓ **Local runtime** — No GitHub dependency management required  

## Persistent owner-runtime deployment

This repository now carries a pinned, running owner-runtime family. See [.keddeh/README.md](.keddeh/README.md) for launch, state retention, VFS subscription and operating scope; [deployment readbacks](.keddeh/deployment-evidence.json) identify the actual engine and cached package digest. The [distributed package](packages/owner-family/README.md) includes its wheel, qualification result and per-process/action/configuration guides. Customer-frontage publication and independent production assessment remain separate from this cloud-host deployment.
