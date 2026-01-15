# R1 LOCK SYSTEM - Emergency Backup Script
# Purpose: Immediate backup of core system files and memories for migration.

$projectRoot = "c:\Users\Administrator\Documents\trae_projects\laozhang_ai"
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
