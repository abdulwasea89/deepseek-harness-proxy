# DeepSeek Official

DeepSeek's own models in `dsh`, routed through the `deepseek-official`
provider (`dsh-llm-deepseek` adapter). No proxy needed — requests go directly
to DeepSeek's API.

Current setup on this machine: model `deepseek-v4-flash` is the default.

## Applied dsh config

The `deepseek-official` route is handled by the built-in `dsh-llm-deepseek`
adapter (not `llm-pi-ai`), so it needs no entry under `llm-pi-ai.providers`.

`~/.dsh/settings.yaml`:

```yaml
agent-default-model:
  provider: deepseek-official
  model: deepseek-v4-flash
  reasoningEffort: low
```

`~/.dsh/.credentials.yaml`:

```yaml
refs:
  DEEPSEEK_API_KEY: sk-REPLACE_WITH_YOUR_KEY
```

See [`dsh/settings.yaml.example`](dsh/settings.yaml.example).

## Coexistence with AgentRouter

Both providers live in the same dsh install:

- `deepseek-official` → direct, built-in adapter.
- `agentrouter` → `llm-pi-ai` adapter → local proxy → AgentRouter gateway.

Pick the model in the dsh UI at runtime; both routes stay configured.

## Verify

```bash
./scripts/test-deepseek.sh
# HTTP 200 with a short chat-completion reply
```