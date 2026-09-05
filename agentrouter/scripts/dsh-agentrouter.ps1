# Launch AgentRouter proxy (if needed) + DeepSeek Hermes web UI (Windows PowerShell).
# Usage: .\dsh-agentrouter.ps1
$ErrorActionPreference = "Stop"

$proxy = Join-Path $env:USERPROFILE ".dsh\bin\agentrouter-proxy.mjs"
$port = if ($env:DSH_AGENTROUTER_PROXY_PORT) { [int]$env:DSH_AGENTROUTER_PROXY_PORT } else { 8765 }

function Test-PortOpen {
    try {
        $c = New-Object System.Net.Sockets.TcpClient
        $result = $c.BeginConnect("127.0.0.1", $port, $null, $null)
        $success = $result.AsyncWaitHandle.WaitOne(300)
        if ($success -and $c.Connected) { $true } else { $false }
        $c.Close()
    } catch { $false }
}

$started = $false
$proc = $null
if (-not (Test-PortOpen)) {
    if (-not (Test-Path $proxy)) { throw "proxy not found: $proxy (run os/windows/setup.ps1 first)" }
    $proc = Start-Process -FilePath "node" -ArgumentList $proxy -PassThru -WindowStyle Hidden
    $started = $true
    for ($i = 0; $i -lt 50; $i++) {
        if (Test-PortOpen) { break }
        Start-Sleep -Milliseconds 100
    }
    if (-not (Test-PortOpen)) { throw "agentrouter-proxy failed to start on port $port" }
} else {
    Write-Host "agentrouter-proxy already running on port $port"
}

try {
    npx @deepseek-ai/dsh web @args
} finally {
    if ($started -and $proc -and -not $proc.HasExited) {
        Stop-Process -Id $proc.Id -Force
    }
}