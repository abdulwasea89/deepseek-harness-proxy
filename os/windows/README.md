# Windows installer (PowerShell)

Deploys the AgentRouter + DeepSeek Hermes setup on Windows. Uses the same
Node.js proxy and a PowerShell launcher.

## Requirements

- Windows 10/11
- Node.js 18+ — install from https://nodejs.org (adds `npx` and `node` to
  PATH). Alternatively `winget install OpenJS.NodeJS.LTS`.
- PowerShell (ships with Windows).

## Usage

Open **PowerShell** and run:

```powershell
cd os\windows
Set-ExecutionPolicy -Scope Process Bypass   # one-time, current session only
.\setup.ps1
```

What it does:

1. Checks `node` and `npx` are on PATH.
2. Copies `agentrouter-proxy.mjs` → `%USERPROFILE%\.dsh\bin\`.
3. Copies `dsh-agentrouter.ps1` → `%USERPROFILE%\.dsh\`.
4. Writes `%USERPROFILE%\.dsh\settings.yaml` with the `agentrouter` route
   unless one already exists.
5. Adds `AGENTROUTER_API_KEY` to `%USERPROFILE%\.dsh\.credentials.yaml`
   (prompts for the key).
6. Runs the connection test through the proxy (`Invoke-RestMethod`).

## Run

```powershell
cd $env:USERPROFILE\.dsh
.\dsh-agentrouter.ps1        # starts proxy then launches dsh web
```

Or from anywhere:

```powershell
& "$env:USERPROFILE\.dsh\dsh-agentrouter.ps1"
```

## Notes

- Windows Defender may show a firewall prompt for Node when the proxy starts —
  allow it (loopback only).
- If `npx` is not found, reinstall Node or check that the npm bin directory
  (`%APPDATA%\npm`) is on your PATH.