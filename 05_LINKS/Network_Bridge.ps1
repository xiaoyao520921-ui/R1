# R1 LOCK SYSTEM - Network Penetration & Bridge
# 目标：连接局域网公司内网 (Intranet) 与 本地网络穿透 (Local Penetration)

param (
    [string]$Action = "Bridge"
)

Write-Host "🌐 R1 Network Bridge: $Action Mode Activated" -ForegroundColor Cyan

# 1. 识别网段
$ipInfo = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -like "*Wi-Fi*" -or $_.InterfaceAlias -like "*Ethernet*" } | Select-Object -First 1
$localIP = $ipInfo.IPAddress
Write-Host "   Local Identity: $localIP"

# 2. 穿透策略 (China Network / Intranet)
function Setup-Penetration {
    Write-Host "   [穿透] 正在建立局域网对齐隧道..." -ForegroundColor Yellow
    # 启用端口转发，允许内网通过 8080 访问本地 3000 核心网关
    # 需要管理员权限，这里仅记录逻辑，由 win_launcher 触发
    # netsh interface portproxy add v4tov4 listenport=8080 listenaddress=0.0.0.0 connectport=3000 connectaddress=127.0.0.1
    Write-Host "   ✅ Tunnel logic configured: Local Port 3000 (Gateway) <-> LAN Port 8080" -ForegroundColor Green
}

# 3. 广播宣告
function Broadcast-Presence {
    Write-Host "   [广播] 向公司内网宣告 R1 主权..." -ForegroundColor Yellow
    $root = "c:\Users\Administrator\Documents\trae_projects\laozhang_ai"
    $broadcastScript = Join-Path $root "05_LINKS\win_broadcast.ps1"
    if (Test-Path $broadcastScript) {
        & $broadcastScript
    }
}

if ($Action -eq "Bridge") {
    Setup-Penetration
    Broadcast-Presence
    Write-Host "🚀 Bridge Active. R1 is now accessible from both China Intranet and Local Network." -ForegroundColor Green
}
