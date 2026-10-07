#!/usr/bin/env bash
set -eu

# Unified KEDDEH Runtime Bootstrap
# Supports both internal (codex) and external (production) families
# Single bundle, two separate deployments

FAMILY="${FAMILY:-internal}"
RUNTIME_ROOT="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$RUNTIME_ROOT/.." && pwd)"

echo "[KEDDEH] Bootstrapping unified runtime bundle..."
echo "[FAMILY] Active family: $FAMILY"

# Load family configuration
if [ "$FAMILY" = "external" ]; then
  CONFIG_FILE="$RUNTIME_ROOT/external.config.json"
  ENVIRONMENT="production"
  PUBLIC_FACING="true"
elif [ "$FAMILY" = "internal" ]; then
  CONFIG_FILE="$RUNTIME_ROOT/internal.config.json"
  ENVIRONMENT="development"
  PUBLIC_FACING="false"
else
  echo "[ERROR] Unknown family: $FAMILY"
  exit 1
fi

echo "[CONFIG] Loading: $CONFIG_FILE"

# Create family-specific directories
echo "[BOOTSTRAP] Creating directory structure for $FAMILY family..."
mkdir -p "$REPO_ROOT/runtime/.state/$FAMILY"
mkdir -p "$REPO_ROOT/runtime/logs/$FAMILY"
mkdir -p "$REPO_ROOT/runtime/dns/$FAMILY"
mkdir -p "$REPO_ROOT/runtime/boot/$FAMILY"
mkdir -p "$REPO_ROOT/runtime/certs"

if [ "$FAMILY" = "external" ]; then
  mkdir -p "$REPO_ROOT/sites/keddeh.com/public"
  mkdir -p "$REPO_ROOT/runtime/dns/external"
else
  mkdir -p "$REPO_ROOT/sites/keddeh.com/internal"
  mkdir -p "$REPO_ROOT/runtime/dns/internal"
fi

# Create shared core runtime
echo "[CORE] Initializing shared runtime core..."
mkdir -p "$REPO_ROOT/runtime/core"
mkdir -p "$REPO_ROOT/runtime/services"
mkdir -p "$REPO_ROOT/packages/html"

# Write family-specific resolver
echo "[DNS] Creating $FAMILY DNS resolver..."
cat > "$REPO_ROOT/runtime/dns/$FAMILY/resolver.html" <<EOF
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>KEDDEH DNS Resolver ($FAMILY)</title>
    <style>
      body {
        margin: 0;
        font-family: Arial, Helvetica, sans-serif;
        background: #0d1722;
        color: #e8f7ff;
      }
      .wrap {
        max-width: 760px;
        margin: 80px auto;
        background: #111f2b;
        border: 1px solid #24486b;
        border-radius: 12px;
        padding: 28px;
      }
      .family-tag {
        display: inline-block;
        background: $([ "$FAMILY" = "external" ] && echo '#ff6b35' || echo '#4a90e2');
        color: white;
        padding: 4px 10px;
        border-radius: 4px;
        font-size: 0.8em;
        font-weight: bold;
        margin-right: 8px;
      }
      h1 { margin-top: 0; }
      code {
        background: #07111b;
        padding: 2px 6px;
        border-radius: 4px;
      }
    </style>
  </head>
  <body>
    <div class="wrap">
      <span class="family-tag">$FAMILY</span>
      <h1>KEDDEH DNS Resolver</h1>
      <p><strong>Family:</strong> $FAMILY</p>
      <p><strong>Environment:</strong> $ENVIRONMENT</p>
      <p><strong>Public Facing:</strong> $PUBLIC_FACING</p>
      <p><strong>Zone Root:</strong> <code>runtime/dns/$FAMILY</code></p>
    </div>
  </body>
</html>
EOF

echo "[RESOLVER] $FAMILY resolver created"

# Write family-specific web root index
echo "[WEB] Creating $FAMILY web root..."
cat > "$REPO_ROOT/sites/keddeh.com/${FAMILY}/index.html" <<EOF
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>KEDDEH.COM ($FAMILY)</title>
    <style>
      :root {
        --bg: #07111d;
        --panel: #0d1d2d;
        --line: #214a6d;
        --text: #dfefff;
        --muted: #9bb7d1;
        --accent: $([ "$FAMILY" = "external" ] && echo '#ff6b35' || echo '#5ec5ff');
      }
      * { box-sizing: border-box; }
      body {
        margin: 0;
        background: linear-gradient(180deg, #07111d, #0b1c2a 40%, #091722);
        color: var(--text);
        font-family: Arial, Helvetica, sans-serif;
      }
      .wrap {
        max-width: 980px;
        margin: 0 auto;
        padding: 56px 24px 80px;
      }
      .panel {
        background: rgba(13, 29, 45, 0.9);
        border: 1px solid var(--line);
        border-radius: 16px;
        padding: 32px;
        box-shadow: 0 16px 38px rgba(0,0,0,0.25);
      }
      .family-label {
        display: inline-block;
        background: var(--accent);
        color: #000;
        padding: 6px 12px;
        border-radius: 6px;
        font-size: 0.8em;
        font-weight: bold;
        text-transform: uppercase;
        margin-bottom: 12px;
      }
      h1 {
        margin: 0 0 16px;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        font-size: clamp(2rem, 4vw, 4rem);
      }
      p {
        color: var(--muted);
        line-height: 1.8;
      }
    </style>
  </head>
  <body>
    <div class="wrap">
      <div class="panel">
        <div class="family-label">$FAMILY</div>
        <h1>KEDDEH.COM</h1>
        <p>
          This is the <strong>$FAMILY</strong> runtime instance of KEDDEH.COM.
          Environment: <code>$ENVIRONMENT</code>
        </p>
        <p>
          Part of unified dual-family runtime bundle with sibling assimilation sync.
        </p>
      </div>
    </div>
  </body>
</html>
EOF

echo "[WEB] $FAMILY web root initialized"

# Create family-specific runtime manifest
echo "[MANIFEST] Creating $FAMILY runtime manifest..."
cat > "$REPO_ROOT/runtime/boot/$FAMILY/manifest.json" <<EOF
{
  "family": "$FAMILY",
  "environment": "$ENVIRONMENT",
  "public_facing": $PUBLIC_FACING,
  "bundle_version": "1.0.0",
  "initialized_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "state_root": "runtime/.state/$FAMILY",
  "log_root": "runtime/logs/$FAMILY",
  "dns_root": "runtime/dns/$FAMILY",
  "site_root": "sites/keddeh.com/$FAMILY"
}
EOF

echo "[MANIFEST] Manifest written to runtime/boot/$FAMILY/manifest.json"

# Sibling assimilation metadata (for external family)
if [ "$FAMILY" = "external" ]; then
  echo "[SYNC] Configuring sibling assimilation..."
  cat > "$REPO_ROOT/runtime/boot/external/assimilation.json" <<EOF
{
  "sync_enabled": true,
  "source_repo": "Keddeh1/SERVERSPACE",
  "source_branch": "codex",
  "target_repo": "Keddeh1/SERVERSPACE-EXTERNAL",
  "target_branch": "production",
  "sync_direction": "unidirectional_pull",
  "last_sync": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "next_sync": "automatic_on_codex_update"
}
EOF
  echo "[SYNC] Assimilation metadata configured"
fi

echo ""
echo "========================================"
echo "✓ KEDDEH Unified Runtime Bundle"
echo "✓ Family: $FAMILY"
echo "✓ Environment: $ENVIRONMENT"
echo "✓ Configuration loaded"
echo "========================================"
echo ""
echo "[READY] $FAMILY runtime family initialized and ready"
