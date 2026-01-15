# R1 LOCK SYSTEM - Win Broadcast (Win 广播)
# Purpose: Announce Win system identity and status to the multi-universe network.

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $root
$identityToken = Join-Path $projectRoot "00_ROOT_LINK\world_identity.token"
$timelinePath = Join-Path $projectRoot "00_ROOT_LINK\mainline.timeline"

if (!(Test-Path $identityToken)) {
    Write-Error "Identity token not found at $identityToken"
    exit 1
}

$token = Get-Content $identityToken | ConvertFrom-Json
$identity = $token.identity
$universe = $token.alignment.current
$ports = $token.universePorts

Write-Host "📡 [WIN-BROADCAST] Initializing broadcast from $universe ($identity)..." -ForegroundColor Cyan

# 1. Prepare Status Message
$statusMsg = @{
    timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    identity = $identity
    universe = $universe
    status = "ALIVE"
    message = "Win system aligned and broadcasting presence to multi-universe."
    health = @{
        cpu = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
        memory = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
        uptime = (Get-Date) - (Get-Process -Id $PID).StartTime
    }
} | ConvertTo-Json

# 2. Update Mainline Timeline
$timelineEntry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [BROADCAST] $universe ($identity): $message"
if (!(Test-Path $timelinePath)) {
    "--- R1 LOCK SYSTEM MAINLINE TIMELINE ---`n" | Out-File $timelinePath -Encoding utf8
}
$logEntry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [BROADCAST] $universe ($identity) is ALIVE and aligned."
$logEntry | Out-File $timelinePath -Append -Encoding utf8

# 3. Broadcast to Universe Relays
Write-Host "🌐 Broadcasting to universe ports..." -ForegroundColor Yellow
foreach ($u in $ports.PSObject.Properties) {
    $pName = $u.Name
    $pPort = $u.Value
    Write-Host "  -> Sending signal to $pName on port $pPort..." -NoNewline
    try {
        # Simulate broadcast by sending a health ping to the relay
        $response = Invoke-RestMethod -Uri "http://localhost:$pPort/health" -Method Get -Headers @{"x-identity"=$identity; "x-universe"=$universe} -TimeoutSec 2 -ErrorAction SilentlyContinue
        Write-Host " [OK]" -ForegroundColor Green
    } catch {
        Write-Host " [NO-RESPONSE/LOCAL-ONLY]" -ForegroundColor Gray
    }
}

Write-Host "`n✅ [WIN-BROADCAST] Completed. Win system presence is now established across the multi-universe." -ForegroundColor Green
Write-Host "Timeline updated: $timelinePath" -ForegroundColor Gray
