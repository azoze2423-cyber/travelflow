$ErrorActionPreference = "Stop"
$project = $PSScriptRoot
$backend = Join-Path $project "backend"
$ip = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254*' -and ($_.IPAddress -like '192.168.*' -or $_.IPAddress -like '10.*' -or $_.IPAddress -like '172.*') } | Select-Object -First 1 -ExpandProperty IPAddress
if(-not $ip){throw "Could not detect a private LAN IPv4 address."}
Start-Process powershell -ArgumentList @('-NoExit','-ExecutionPolicy','Bypass','-File',"$backend\run_backend.ps1")
Write-Host "Starting backend..." -ForegroundColor Yellow
$ready=$false
for($i=0;$i -lt 180;$i++){
  try { $r=Invoke-WebRequest -UseBasicParsing http://127.0.0.1:8000/health -TimeoutSec 1; if($r.StatusCode -eq 200){$ready=$true;break} } catch {}
  Start-Sleep -Seconds 1
}
if(-not $ready){throw "Backend did not start. Check the backend PowerShell window."}
Write-Host ""; Write-Host "TravelFlow LAN URL: http://$ip`:8080" -ForegroundColor Green
Write-Host "Open that URL on another device connected to the same Wi-Fi." -ForegroundColor Cyan
Write-Host "If Windows Firewall asks, allow access on Private networks." -ForegroundColor Yellow
Set-Location $project
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 --dart-define=API_URL=http://$ip`:8000
