Param(
  [string]$Action = "health"
)
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$localNodeDir = Join-Path $root "node_env\node-v20.11.0-win-x64"
$nodeExe = "node"
$npmCmd = "npm"
if (Test-Path (Join-Path $localNodeDir "node.exe")) {
    $nodeExe = Join-Path $localNodeDir "node.exe"
    $npmCmd = Join-Path $localNodeDir "npm.cmd"
    $env:PATH = "$localNodeDir;" + $env:PATH
}

$config = Join-Path $root "apps.json"
if (!(Test-Path $config)) {
  $config = Join-Path $root "apps.example.json"
}
$json = Get-Content $config -Raw | ConvertFrom-Json
$apps = $json.apps
$junctions = $json.junctions
Function Start-App($app) {
  if ($app.type -eq "node") {
    $pm2 = Get-Command pm2 -ErrorAction SilentlyContinue
    if ($pm2) {
      if ($app.cwd -and (Test-Path $app.cwd)) {
        pm2 start $app.path --name $app.name --cwd $app.cwd --time
      } else {
        pm2 start $app.path --name $app.name --time
      }
    } else {
      if ($app.cwd -and (Test-Path $app.cwd)) {
        Write-Output "Starting node app $($app.name) at $($app.path) with cwd $($app.cwd)"
        Start-Process $nodeExe -ArgumentList $app.path -WorkingDirectory $app.cwd
      } else {
        Write-Output "Starting node app $($app.name) at $($app.path) (no cwd)"
        Start-Process $nodeExe -ArgumentList $app.path
      }
    }
  } elseif ($app.type -eq "ps1") {
    $psexe = Join-Path $env:WINDIR "System32\\WindowsPowerShell\\v1.0\\powershell.exe"
    Start-Process $psexe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($app.path)`""
  }
}
Function Stop-App($app) {
  if ($app.type -eq "node") {
    $pm2 = Get-Command pm2 -ErrorAction SilentlyContinue
    if ($pm2) {
      pm2 stop $app.name
    }
  }
}
Function Restart-App($app) {
  if ($app.type -eq "node") {
    $pm2 = Get-Command pm2 -ErrorAction SilentlyContinue
    if ($pm2) {
      pm2 restart $app.name
    }
  }
}
Function Health-App($app) {
  try {
    $r = Invoke-WebRequest -Uri $app.health -UseBasicParsing -TimeoutSec 3
    Write-Output "$($app.name): $($r.StatusCode)"
  } catch {
    Write-Output "$($app.name): down"
  }
}
Function Make-Junction($j) {
  if (Test-Path $j.old) {
    try {
      Rename-Item $j.old ("{0}_old" -f ([System.IO.Path]::GetFileName($j.old))) -ErrorAction SilentlyContinue
    } catch {}
  }
  New-Item -ItemType Junction -Path $j.old -Target $j.new -ErrorAction SilentlyContinue
}
switch ($Action) {
  "start" { $apps | ForEach-Object { Start-App $_ } }
  "stop" { $apps | ForEach-Object { Stop-App $_ } }
  "restart" { $apps | ForEach-Object { Restart-App $_ } }
  "health" { $apps | ForEach-Object { Health-App $_ } }
  "junctions" { $junctions | ForEach-Object { Make-Junction $_ } }
  "autorun" {
    $pm2 = Get-Command pm2 -ErrorAction SilentlyContinue
    if ($pm2) {
      pm2 save
      pm2 startup powershell
    }
  }
  "broadcast" {
    $broadcastScript = Join-Path $root "05_LINKS\win_broadcast.ps1"
    if (Test-Path $broadcastScript) {
      & $broadcastScript
    } else {
      Write-Error "Broadcast script not found at $broadcastScript"
    }
  }
}
