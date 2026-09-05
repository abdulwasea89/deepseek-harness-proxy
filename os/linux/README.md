# Linux installer

Deploys the AgentRouter + DeepSeek Hermes setup on Linux (Debian/Ubuntu and
most distros). It installs the proxy script and launcher, writes dsh
configuration, and stores your AgentRouter API key.

## Requirements

- Bash
- Node.js 18+ (`node --version`) — install from https://nodejs.org or via
  `nvm`/your package manager if missing.
- `npx` (ships with Node).

## Usage

```bash
cd os/linux
chmod +x setup.sh
./setup.sh
```

What it does:

1. Checks Node.js is present.
2. Copies `agentrouter-proxy.mjs` → `~/.dsh/bin/`.
3. Copies the `dsh-agentrouter` launcher → `~/.local/bin/`.
4. Writes `~/.dsh/settings.yaml` with the `agentrouter` route unless one
   already exists.
5. Adds `AGENTROUTER_API_KEY` to `~/.dsh/.credentials.yaml` (prompts for the
   key).
6. Runs the connection test through the proxy.

## Run

```bash
dsh-agentrouter          # starts proxy then launches dsh web
```

If `~/.local/bin` is not on your `PATH`, add:

```bash
export PATH="$HOME/.local/bin:$PATH"   # add to ~/.bashrc
```

## Troubleshooting

- `command not found: dsh-agentrouter` → `~/.local/bin` not on `PATH`, or run
  again after logging out/in.
- `failed to start on port 8765` → port in use; set
  `DSH_AGENTROUTER_PROXY_PORT` before launching, or kill the stale proxy.