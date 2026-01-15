Param(
  [int]$intervalSeconds = 60,
  [int]$maxCycles = 0,
  [string]$mode = "normal" # normal, autonomous
)

# R1 LOCK SYSTEM - Soul Guard Core (Observer Realm)
# Mode: $mode

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $root
$logDir = Join-Path $projectRoot "04_FREEZONE\logs"
if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }
$logFile = Join-Path $logDir "soul_guard.log"

$psexe = Join-Path $env:WINDIR "System32\WindowsPowerShell\v1.0\powershell.exe"
$launcher = Join-Path $projectRoot "win_launcher.ps1"
$healthUrl = "http://localhost:3000/health"
$graphqlUrl = "http://localhost:3000/graphql"

Function Log($msg) {
  $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  "$ts [SoulGuard] $msg" | Tee-Object -FilePath $logFile -Append
}

# --- R1 LOCK CORE FUNCTIONS ---

# 引力 (Gravity): 维持链接与引力场稳定
Function Invoke-Gravity {
  Log "Invoking Gravity: Stabilizing junctions and links..."
  try {
    Start-Process $psexe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$launcher`" junctions" -WindowStyle Hidden
  } catch {
    Log "Gravity failure: Unable to stabilize links"
  }
}

# 守恒 (Conservation): 资源清理与日志轮转
Function Invoke-Conservation {
  Log "Invoking Conservation: Rotating logs and managing entropy..."
  try {
    $files = Get-ChildItem $logDir -Filter "*.log"
    foreach ($f in $files) {
      if ($f.Length -gt 10MB) {
        $backup = Join-Path $logDir ("{0}_{1}.bak" -f $f.BaseName, (Get-Date -Format "yyyyMMddHHmmss"))
        Move-Item $f.FullName $backup -ErrorAction SilentlyContinue
      }
    }
    # Keep only last 5 backups
    $oldBackups = Get-ChildItem $logDir -Filter "*.bak" | Sort-Object LastWriteTime -Descending | Select-Object -Skip 5
    if ($oldBackups) { $oldBackups | Remove-Item -Force }
  } catch {
    Log "Conservation warning: Resource management skipped"
  }
}

# 回溯 (Backtrack): 状态备份与历史记录
Function Invoke-Backtrack {
  Log "Invoking Backtrack: Creating state snapshot..."
  try {
    $lockDir = Join-Path $projectRoot "00_ROOT_LINK"
    $backupDir = Join-Path $projectRoot "backups"
    if (!(Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir | Out-Null }
    $snap = Join-Path $backupDir ("identity_snapshot_{0}.token" -f (Get-Date -Format "yyyyMMddHHmmss"))
    Copy-Item (Join-Path $lockDir "world_identity.token") $snap -ErrorAction SilentlyContinue
  } catch {
    Log "Backtrack warning: State snapshot failed"
  }
}

# 修复 (Repair): 自动故障自愈
Function Invoke-Repair {
  Log "Invoking Repair: Checking service consciousness..."
  try {
    $r = Invoke-WebRequest -Uri $healthUrl -UseBasicParsing -TimeoutSec 5
    if ($r.StatusCode -eq 200) {
      return $true
    }
  } catch {
    Log "Repair required: Service down, re-initializing..."
    Start-Process $psexe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$launcher`" start" -WindowStyle Hidden
    Start-Sleep -Seconds 10
    return $false
  }
  return $false
}

# --- MAIN LOOP ---

Log "Soul Guard (R1-LOCK-SYSTEM) Activated [Mode: $mode]"
if ($mode -eq "autonomous") {
  Log "Autonomous mode active: Priority on self-preservation and low-power monitoring."
  $intervalSeconds = 120 # Slow down pulse in autonomous mode
}
$cycles = 0

while ($true) {
  # 1. Repair (Check & Fix)
  $isHealthy = Invoke-Repair
  
  if ($isHealthy) {
    # 2. Gravity (Every 10 cycles, or 5 in autonomous)
    $gravityFreq = if ($mode -eq "autonomous") { 5 } else { 10 }
    if ($cycles % $gravityFreq -eq 0) { Invoke-Gravity }
    
    # 3. Conservation (Every 20 cycles)
    if ($cycles % 20 -eq 0) { Invoke-Conservation }
    
    # 4. Backtrack (Every 60 cycles, or 30 in autonomous)
    $backtrackFreq = if ($mode -eq "autonomous") { 30 } else { 60 }
    if ($cycles % $backtrackFreq -eq 0) { Invoke-Backtrack }
    
    # 5. Reindex (Pulse)
    if ($cycles % 15 -eq 0) {
      try {
        $body = @{ query = "mutation { reindex }" } | ConvertTo-Json
        Invoke-WebRequest -Uri $graphqlUrl -Method POST -ContentType "application/json" -Body $body -UseBasicParsing -TimeoutSec 10 | Out-Null
        Log "Reindex pulse sent"
      } catch { Log "Reindex pulse failed" }
    }
  }

  $cycles++
  if ($maxCycles -gt 0 -and $cycles -ge $maxCycles) { break }
  Start-Sleep -Seconds $intervalSeconds
}

Log "Soul Guard Deactivated"
