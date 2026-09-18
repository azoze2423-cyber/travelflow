$ErrorActionPreference = "Stop"
$project = $PSScriptRoot
$backend = Join-Path $project "backend"
Start-Process powershell -ArgumentList @('-NoExit','-ExecutionPolicy','Bypass','-File',"$backend\run_backend.ps1")
Write-Host "Starting backend..." -ForegroundColor Yellow
$ready=$false
for($i=0;$i -lt 180;$i++){
  try { $r=Invoke-WebRequest -UseBasicParsing http://127.0.0.1:8000/health -TimeoutSec 1; if($r.StatusCode -eq 200){$ready=$true;break} } catch {}
  Start-Sleep -Seconds 1
}
if(-not $ready){throw "Backend did not start. Check the backend PowerShell window."}
Set-Location $project
Write-Host "Backend ready. Opening Flutter..." -ForegroundColor Green
flutter run -d chrome --dart-define=API_URL=http://127.0.0.1:8000
