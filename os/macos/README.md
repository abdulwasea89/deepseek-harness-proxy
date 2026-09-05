# macOS installer

Deploys the AgentRouter + DeepSeek Hermes setup on macOS. Same as the Linux
installer, but for the `~/.local/bin` path convention common on macOS and
notes for Homebrew installs of Node.

## Requirements

- Bash (default on macOS)
- Node.js 18+ (`node --version`) — install with:

  ```bash
  brew install node
  ```

- `curl` (ships with macOS).

## Usage

```bash
cd os/macos
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

If `~/.local/bin` is not on your `PATH`, add to `~/.zshrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Notes

- macOS may gate `~/.local/bin` behind a missing path; `mkdir -p` handles it.
- If Node was installed through Homebrew and `node` is not resolved in your
  launcher environment, set `NODE` explicitly:

  ```bash
  NODE=/opt/homebrew/bin/node dsh-agentrouter
  ```