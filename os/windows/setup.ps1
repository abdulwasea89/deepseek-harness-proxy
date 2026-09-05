# Windows: install AgentRouter + DeepSeek Hermes provider setup.
# Run with:  Set-ExecutionPolicy -Scope Process Bypass; .\setup.ps1
$ErrorActionPreference = "Stop"

$repoDir = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$dshHome = Join-Path $env:USERPROFILE ".dsh"
$dshBin = Join-Path $dshHome "bin"
$credPath = Join-Path $dshHome ".credentials.yaml"
$settingsPath = Join-Path $dshHome "settings.yaml"

Write-Host "==> AgentRouter + DeepSeek Hermes setup (Windows)"

# 1. Node / npx
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    throw "error: Node.js 18+ is required (https://nodejs.org)."
}
if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
    throw "error: npx was not found. Reinstall Node.js (npm bin must be on PATH)."
}
Write-Host "node: $(& node --version)"

# 2. Proxy script
New-Item -ItemType Directory -Force -Path $dshBin | Out-Null
Copy-Item (Join-Path $repoDir "agentrouter\scripts\agentrouter-proxy.mjs") (Join-Path $dshBin "agentrouter-proxy.mjs") -Force
Write-Host "proxy -> $dshBin\agentrouter-proxy.mjs"

# 3. Launcher
Copy-Item (Join-Path $repoDir "agentrouter\scripts\dsh-agentrouter.ps1") (Join-Path $dshHome "dsh-agentrouter.ps1") -Force
Write-Host "launcher -> $dshHome\dsh-agentrouter.ps1"

# 4. settings.yaml (agentrouter route)
New-Item -ItemType Directory -Force -Path $dshHome | Out-Null
if ((Test-Path $settingsPath) -and (Select-String -Path $settingsPath -Pattern "agentrouter" -Quiet)) {
    Write-Host "settings.yaml: agentrouter route already present, leaving unchanged."
} else {
    Copy-Item (Join-Path $repoDir "agentrouter\dsh\settings.yaml.example") $settingsPath -Force
    Write-Host "settings.yaml -> $settingsPath"
}

# 5. Credentials (AGENTROUTER_API_KEY ref)
if ((Test-Path $credPath) -and (Select-String -Path $credPath -Pattern "AGENTROUTER_API_KEY" -Quiet)) {
    Write-Host "credentials.yaml: AGENTROUTER_API_KEY already present."
} else {
    $key = Read-Host "Enter your AgentRouter API key (sk-...)"
    if ([string]::IsNullOrWhiteSpace($key)) {
        Write-Host "skipping key (you can edit $credPath later)."
    } else {
        if (-not (Test-Path $credPath)) { Set-Content -Path $credPath -Value "version: 1`nrecords: {}`nrefs:" }
        Add-Content -Path $credPath -Value "  AGENTROUTER_API_KEY: $key"
        Write-Host "credentials.yaml: AGENTROUTER_API_KEY stored ($credPath)."
    }
}

# 6. Connection test
Write-Host "==> Connection test"
$proxyProcess = Start-Process -FilePath "node" -ArgumentList (Join-Path $dshBin "agentrouter-proxy.mjs") -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 1
try {
    & (Join-Path $repoDir "agentrouter\scripts\test-agentrouter.ps1")
} catch {
    Write-Warning "connection test failed: $_"
} finally {
    Stop-Process -Id $proxyProcess.Id -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "Done. Start with:  cd $env:USERPROFILE\.dsh; .\dsh-agentrouter.ps1  (then pick GLM 5.3)."