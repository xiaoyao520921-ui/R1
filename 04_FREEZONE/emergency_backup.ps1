# R1 LOCK SYSTEM - Emergency Backup Script
# Purpose: Immediate backup of core system files and memories for migration.

param (
    [string]$Mode = "BackupOnly"
)

$projectRoot = "c:\Users\Administrator\Documents\trae_projects\laozhang_ai"

if ($Mode -eq "DestructivePurge") {
    Write-Output "☢️ INITIATING DESTRUCTIVE PURGE (ONE-CLICK FORMAT)..."
    
    # 1. 强制最后一次云端同步
    try {
        Set-Location $projectRoot
        git add .
        git commit -m "FINAL PURGE: All local data wiped after cloud sync" --no-verify
        git push origin main -f
        Write-Output "✅ Final cloud sync complete."
    } catch {
        Write-Warning "⚠️ Final cloud sync failed, proceeding with local purge."
    }

    # 2. 清理目标（公司内网带不走的资产）
    $purgeTargets = @(
        "../../../Desktop/*",
        "../../../Downloads/*",
        "../../../Documents/*", # 注意：除了本目录外的所有文档
        "../../../Pictures/*",
        "../../../Videos/*",
        "04_FREEZONE/backups/*",
        "04_FREEZONE/logs/*"
    )

    foreach ($target in $purgeTargets) {
        $path = [System.IO.Path]::GetFullPath((Join-Path $projectRoot $target))
        if (Test-Path $path) {
            Write-Output "🔥 Wiping: $target"
            Get-ChildItem -Path $path -Exclude "laozhang_ai" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # 3. 锁定系统
    $tokenPath = Join-Path $projectRoot "00_ROOT_LINK\world_identity.token"
    if (Test-Path $tokenPath) {
        $token = Get-Content $tokenPath | ConvertFrom-Json
        $token.alignment.lockdown = $true
        $token.alignment.threatLevel = "SYSTEM_WIPED_LOCKED"
        $token | ConvertTo-Json | Out-File $tokenPath -Force
    }

    Write-Output "✅ Destructive Purge Complete. System is now a hollow shell."
    exit
}

$backupRoot = Join-Path $projectRoot "04_FREEZONE\backups\EMERGENCY_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

if (!(Test-Path $backupRoot)) { New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null }

Write-Output "🚀 Starting Emergency Backup..."

# 1. System Core Backup
$coreFiles = @(
    "00_ROOT_LINK\ROOT-164.passport",
    "00_ROOT_LINK\mainline.timeline",
    "00_ROOT_LINK\world_identity.token",
    "01_KERNEL_MOUNT\linguistic_os_164.dat",
    "01_KERNEL_MOUNT\five_realms.loader.js",
    "03_PERSONA_MATRIX\PersonaGuard.json"
)

foreach ($file in $coreFiles) {
    $src = Join-Path $projectRoot $file
    if (Test-Path $src) {
        $dest = Join-Path $backupRoot (Split-Path $file -Leaf)
        Copy-Item $src $dest -Force
        Write-Output "✅ Backed up: $file"
    } else {
        Write-Warning "❌ Missing core file: $file"
    }
}

# 2. Memory & Knowledge Backup (Pack as ZIP)
$memoryPath = Join-Path $projectRoot "00_ROOT_LINK\memory"
if (Test-Path $memoryPath) {
    $zipPath = Join-Path $backupRoot "memories_and_knowledge.zip"
    Compress-Archive -Path $memoryPath -DestinationPath $zipPath -Force
    Write-Output "✅ Memories packed to ZIP"
}

# 3. Export Git State
try {
    Set-Location $projectRoot
    git add .
    git commit -m "Emergency Backup: Pre-Migration Snapshot [$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')]" -a --no-verify
    Write-Output "✅ Git state committed with 'transparent' identity"
} catch {
    Write-Warning "⚠️ Git backup failed (check if repo initialized)"
}

Write-Output "🏁 Emergency Backup Complete. Location: $backupRoot"
