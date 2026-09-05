#!/usr/bin/env bash
# macOS: install AgentRouter + DeepSeek Hermes provider setup.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
DSH_HOME="${DSH_HOME:-$HOME/.dsh}"
BIN_DIR="$HOME/.local/bin"

echo "==> AgentRouter + DeepSeek Hermes setup (macOS)"

# 1. Node.js
if ! command -v node >/dev/null 2>&1; then
  echo "error: Node.js 18+ is required (brew install node)." >&2
  exit 1
fi
echo "node: $(node --version)"

# 2. Proxy script
mkdir -p "$DSH_HOME/bin"
cp "$REPO_DIR/agentrouter/scripts/agentrouter-proxy.mjs" "$DSH_HOME/bin/agentrouter-proxy.mjs"
chmod +x "$DSH_HOME/bin/agentrouter-proxy.mjs"
echo "proxy -> $DSH_HOME/bin/agentrouter-proxy.mjs"

# 3. Launcher
mkdir -p "$BIN_DIR"
cp "$REPO_DIR/agentrouter/scripts/dsh-agentrouter" "$BIN_DIR/dsh-agentrouter"
chmod +x "$BIN_DIR/dsh-agentrouter"
echo "launcher -> $BIN_DIR/dsh-agentrouter"

# 4. settings.yaml (agentrouter route)
mkdir -p "$DSH_HOME"
if [[ -f "$DSH_HOME/settings.yaml" ]] && grep -q "agentrouter" "$DSH_HOME/settings.yaml" 2>/dev/null; then
  echo "settings.yaml: agentrouter route already present, leaving unchanged."
else
  cp "$REPO_DIR/agentrouter/dsh/settings.yaml.example" "$DSH_HOME/settings.yaml"
  echo "settings.yaml -> $DSH_HOME/settings.yaml"
fi

# 5. Credentials (AGENTROUTER_API_KEY ref)
CRED="$DSH_HOME/.credentials.yaml"
ensure_refs() {
  grep -q "^refs:" "$CRED" 2>/dev/null || { echo "refs:" >>"$CRED"; }
}
if [[ -f "$CRED" ]] && grep -q "AGENTROUTER_API_KEY" "$CRED"; then
  echo "credentials.yaml: AGENTROUTER_API_KEY already present."
else
  read -r -p "Enter your AgentRouter API key (sk-...): " KEY
  if [[ -z "$KEY" ]]; then
    echo "skipping key (you can edit $CRED later)."
  else
    touch "$CRED"
    ensure_refs
    echo "  AGENTROUTER_API_KEY: $KEY" >>"$CRED"
    echo "credentials.yaml: AGENTROUTER_API_KEY stored ($CRED)."
  fi
fi

# 6. Connection test
echo "==> Connection test"
if command -v curl >/dev/null 2>&1; then
  node "$DSH_HOME/bin/agentrouter-proxy.mjs" >/dev/null 2>&1 &
  PROXY_PID=$!
  sleep 1
  "$REPO_DIR/agentrouter/scripts/test-agentrouter.sh" || true
  kill "$PROXY_PID" 2>/dev/null || true
else
  echo "curl not found — skipping connection test."
fi

echo
echo "Done. Start with:  dsh-agentrouter  (then pick GLM 5.3 in dsh)."