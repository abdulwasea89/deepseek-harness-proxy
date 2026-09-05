# AgentRouter (GLM 5.3 via AgentRouter)

Third-party model access through the AgentRouter gateway
(`https://agentrouter.org`). Model id: `glm-5.3`, wire protocol:
**Anthropic Messages** (`post /v1/messages`).

## How it fits into dsh

dsh routes third-party providers through the `llm-pi-ai` adapter, configured in
`~/.dsh/settings.yaml` under `llm-pi-ai.providers`. The route is named
`agentrouter` and the model entry is `glm-5.3`.

Because of AgentRouter's `User-Agent` fingerprinting, the real `baseURL` in dsh
is the local proxy `http://127.0.0.1:8765` — never `https://agentrouter.org`
directly (that always returns `401 unauthorized client detected`).

## Applied dsh config

`~/.dsh/settings.yaml`:

```yaml
llm-pi-ai:
  providers:
    agentrouter:
      displayName: AgentRouter
      api: anthropic-messages
      baseURL: http://127.0.0.1:8765
      apiKeyEnv: AGENTROUTER_API_KEY
      models:
        - id: glm-5.3
          name: GLM 5.3
```

`~/.dsh/.credentials.yaml` (add your real key; never commit it):

```yaml
refs:
  AGENTROUTER_API_KEY: sk-REPLACE_WITH_YOUR_KEY
```

See [`dsh/settings.yaml.example`](dsh/settings.yaml.example) and
[`dsh/credentials.yaml.example`](dsh/credentials.yaml.example).

## The proxy

`scripts/agentrouter-proxy.mjs` is a dependency-free Node server that:

- listens on `127.0.0.1:8765`
- rewrites the `User-Agent` header to `opencode/2`
- forwards every request verbatim to `https://agentrouter.org` (same path,
  method, and body — streams SSE untouched)

Start it manually (without the launcher):

```bash
node scripts/agentrouter-proxy.mjs
```

Configurable via env:

| Env | Default |
|---|---|
| `DSH_AGENTROUTER_PROXY_PORT` | `8765` |
| `DSH_AGENTROUTER_UA` | `opencode/2` |

## Launchers

`dsh-agentrouter` (macOS/Linux) and `dsh-agentrouter.ps1` (Windows) start the
proxy if it is not already running, wait for the port, then exec
`npx @deepseek-ai/dsh web`.

## Troubleshooting

- **`401 unauthorized client detected`** on the direct gateway URL — expected.
  Only sends through the proxy or with a `User-Agent: opencode/*`.
- **`invalid API key` inside dsh** — usually the old/rotated key or the request
  went straight to agentrouter (check the route `baseURL` is
  `http://127.0.0.1:8765`).
- **Proxy not running** — start it, then retry; dsh re-reads configuration per
  request.

## Verify

```bash
./scripts/test-agentrouter.sh
# HTTP 200 with a "PONG" assistant response from glm-5.3
```