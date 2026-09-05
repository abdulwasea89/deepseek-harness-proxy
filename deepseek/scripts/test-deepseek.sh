#!/usr/bin/env bash
# Verify the DeepSeek Official API key against api.deepseek.com.
set -euo pipefail

MODEL="${1:-deepseek-chat}"
KEY="${DEEPSEEK_API_KEY:-}"

if [[ -z "$KEY" ]]; then
  CRED_FILE="${DSH_HOME:-$HOME/.dsh}/.credentials.yaml"
  if [[ -f "$CRED_FILE" ]] && grep -q "DEEPSEEK_API_KEY" "$CRED_FILE"; then
    KEY="$(grep "DEEPSEEK_API_KEY:" "$CRED_FILE" | head -1 | sed 's/.*DEEPSEEK_API_KEY:[[:space:]]*//')"
  fi
fi
if [[ -z "$KEY" ]]; then
  echo "error: no API key. Export DEEPSEEK_API_KEY or install ~/.dsh/.credentials.yaml" >&2
  exit 1
fi

echo "==> POST https://api.deepseek.com/chat/completions (model=$MODEL)"
code="$(curl -s -o /tmp/deepseek-test.json -w "%{http_code}" \
  -X POST "https://api.deepseek.com/chat/completions" \
  -H "Authorization: Bearer $KEY" \
  -H "content-type: application/json" \
  -d "{\"model\":\"$MODEL\",\"max_tokens\":10,\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}]}")"

echo "HTTP $code"
cat /tmp/deepseek-test.json
echo

if [[ "$code" == "200" ]]; then
  echo "OK: DeepSeek Official key is valid."
else
  echo "FAILED: check the key and network access to api.deepseek.com." >&2
  exit 1
fi