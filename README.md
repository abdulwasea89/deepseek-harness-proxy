# AgentRouter + DeepSeek Hermes (dsh)

Run **AgentRouter (GLM 5.3)** and **DeepSeek Official** models side by side in
DeepSeek Hermes (`dsh`, the web CLI started with `npx @deepseek-ai/dsh web`).

This repo documents the setup, ships the required scripts, and provides a
per-OS installer under [`os/`](os/).

## The problem this solves

AgentRouter's gateway authenticates by **User-Agent fingerprinting**: it only
accepts requests whose `User-Agent` matches `opencode/<version>` (we verified
`opencode/1`, `opencode/2`, `opencode/2.0.0` are accepted; everything else gets
`401 unauthorized client detected`).

DeepSeek Hermes **hard-codes** `User-Agent: deepseek-harness/<version> (...)`
on every request and offers no setting to override it — colliding headers in
the provider config get stripped (see `dsh-llm` `attributionHeaders()`).

So dsh cannot talk to AgentRouter directly. The fix is a tiny local reverse
proxy (`agentrouter/scripts/agentrouter-proxy.mjs`) that rewrites the
`User-Agent` header to `opencode/2` and forwards to `https://agentrouter.org`.

```
dsh ──▶ http://127.0.0.1:8765 ──(UA rewritten to opencode/2)──▶ https://agentrouter.org
```

DeepSeek Official needs no proxy — it goes straight to `api.deepseek.com`.

## Layout

```
agentrouter-deepseek/
├── agentrouter/           # third-party GLM 5.3 via AgentRouter gateway
│   ├── README.md          # connect guide + config reference
│   ├── dsh/               # config examples for dsh (~/.dsh)
│   │   ├── settings.yaml.example
│   │   └── credentials.yaml.example
│   └── scripts/           # proxy, launchers, connection test
│       ├── agentrouter-proxy.mjs
│       ├── dsh-agentrouter            # macOS / Linux launcher
│       ├── dsh-agentrouter.ps1        # Windows launcher
│       └── test-agentrouter.sh        # end-to-end connection test
├── deepseek/              # DeepSeek Official route
│   ├── README.md
│   ├── dsh/settings.yaml.example
│   └── scripts/test-deepseek.sh       # API-key connection test
└── os/                    # per-OS installers and guides
    ├── linux/   README.md + setup.sh
    ├── macos/   README.md + setup.sh
    └── windows/ README.md + setup.ps1
```

## Quick start (macOS / Linux / WSL)

```bash
cd os/linux        # or os/macos
./setup.sh            # deploys config + scripts, asks for your AgentRouter key
dsh-agentrouter       # starts the proxy, then launches DeepSeek Hermes
# in the UI pick the "GLM 5.3" model
```

Windows: run `os/windows/setup.ps1` in PowerShell, then launch with
`dsh-agentrouter.ps1`.

## Testing

- `agentrouter/scripts/test-agentrouter.sh` — end-to-end GLM 5.3 request through the proxy.
- `deepseek/scripts/test-deepseek.sh` — verifies the DeepSeek Official key.

## Files that live on your machine

| Path | Purpose |
|---|---|
| `~/.dsh/settings.yaml` | provider routes read by dsh (`llm-pi-ai.providers`) |
| `~/.dsh/.credentials.yaml` | API keys resolved per request (`AGENTROUTER_API_KEY`, `DEEPSEEK_API_KEY`) |
| `~/.dsh/bin/agentrouter-proxy.mjs` | installed proxy script |
| `~/.local/bin/dsh-agentrouter` | installed launcher (macOS/Linux) |