# Запуск с логированием stdout/stderr
# Usage: .\scripts\run_with_log.ps1 [Debug|Release]
param(
  [string]$config = 'Debug'
)

if ($config -eq 'Release') {
  $exe = "build\windows\x64\runner\Release\moskow_stock_spplication.exe"
} else {
  $exe = "build\windows\x64\runner\Debug\moskow_stock_spplication.exe"
}

if (-not (Test-Path $exe)) {
  Write-Error "Executable not found: $exe. Build first with 'flutter build windows --$config' or 'flutter run -d windows'."
  exit 1
}

$log = "logs\app_stdout.log"
$err = "logs\app_stderr.log"

if (-not (Test-Path "logs")) { New-Item -ItemType Directory -Path logs | Out-Null }

Write-Output "Starting application: $exe"
Start-Process -FilePath $exe -NoNewWindow -PassThru -RedirectStandardOutput $log -RedirectStandardError $err
Write-Output "Logs: $log and $err"

