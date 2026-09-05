# End-to-end check: GLM 5.3 via the local proxy (anthropic-messages protocol).
param(
    [string]$Base = "http://127.0.0.1:8765",
    [string]$Model = "glm-5.3"
)
$ErrorActionPreference = "Stop"

$key = if ($env:AGENTROUTER_API_KEY) {
    $env:AGENTROUTER_API_KEY
} else {
    $credPath = Join-Path $env:USERPROFILE ".dsh\.credentials.yaml"
    $match = Select-String -Path $credPath -Pattern "AGENTROUTER_API_KEY:\s*(\S+)" -ErrorAction SilentlyContinue
    if ($match) { $match.Matches[0].Groups[1].Value } else { $null }
}

if ([string]::IsNullOrWhiteSpace($key)) {
    throw "error: no API key. Set AGENTROUTER_API_KEY or install ~/.dsh/.credentials.yaml"
}

Write-Host "==> POST $Base/v1/messages (model=$Model)"
$body = @{
    model     = $Model
    max_tokens = 30
    messages  = @(@{ role = "user"; content = "reply with exactly: PONG" })
} | ConvertTo-Json -Depth 5

try {
    $resp = Invoke-RestMethod -Method Post -Uri "$Base/v1/messages" -Headers @{
        "x-api-key"         = $key
        "anthropic-version" = "2023-06-01"
    } -ContentType "application/json" -Body $body
    Write-Host "OK: agentrouter + glm-5.3 reachable through the proxy."
    Write-Host "model: $($resp.model) | role: $($resp.role)"
} catch {
    Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}