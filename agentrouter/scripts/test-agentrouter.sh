#!/usr/bin/env bash
# End-to-end check: GLM 5.3 via the local proxy (anthropic-messages protocol).
set -euo pipefail

BASE="${1:-http://127.0.0.1:8765}"
MODEL="${2:-glm-5.3}"
KEY="${AGENTROUTER_API_KEY:-}"

if [[ -z "$KEY" ]]; then
  CRED_FILE="${DSH_HOME:-$HOME/.dsh}/.credentials.yaml"
  if [[ -f "$CRED_FILE" ]] && grep -q "AGENTROUTER_API_KEY" "$CRED_FILE"; then
    KEY="$(grep "AGENTROUTER_API_KEY:" "$CRED_FILE" | head -1 | sed 's/.*AGENTROUTER_API_KEY:[[:space:]]*//')"
  fi
fi
if [[ -z "$KEY" ]]; then
  echo "error: no API key. Export AGENTROUTER_API_KEY or install ~/.dsh/.credentials.yaml" >&2
  exit 1
fi

echo "==> POST $BASE/v1/messages (model=$MODEL)"
code="$(curl -s -o /tmp/agentrouter-test.json -w "%{http_code}" \
  -X POST "$BASE/v1/messages" \
  -H "x-api-key: $KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d "{\"model\":\"$MODEL\",\"max_tokens\":30,\"messages\":[{\"role\":\"user\",\"content\":\"reply with exactly: PONG\"}]}")"

echo "HTTP $code"
cat /tmp/agentrouter-test.json
echo

if [[ "$code" == "200" ]]; then
  echo "OK: agentrouter + glm-5.3 reachable through the proxy."
else
  echo "FAILED: check key and that the proxy is running (node agentrouter-proxy.mjs)." >&2
  exit 1
fi